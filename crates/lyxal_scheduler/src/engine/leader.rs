//! Planificateur (W1, W2) : un seul nœud, sous le bail d'élection `leader` du runtime (clé
//! `scheduler`, 30 s, renouvelé toutes les 10 s). À chaque tour (1 s) : planifications dues
//! (dates manquées et suivante calculées par `spec`, décalage aléatoire U5 appliqué à la date de
//! disponibilité), rejeux de période ; toutes les 30 s, reprise des baux expirés ; toutes les
//! heures, élagage. Sans bail : attend. Chaque écriture du planificateur porte la garde de
//! génération du bail (`node`, `generation` : Y2) : un nœud qui a perdu le bail, même au milieu
//! d'un tour ou entre deux lots d'un rejeu, est refusé (`SCHEDULER_LEADER_FENCED`), oublie son
//! bail et cesse de planifier ; une même échéance ne crée jamais deux exécutions (identifiant
//! `[planification, date]`). Les règles d'une planification sont recontrôlées à chaque calcul
//! (écart d'au moins une minute U1, décalage U5) : des règles écrites directement en SurrealQL
//! qui ne les respectent pas rendent la planification invalide.

use async_trait::async_trait;
use jiff::{SignedDuration, Timestamp};
use lyxal_runtime::lock::{AcquireLeaderLeaseResult, LeaderLease, SurrealLeaderLeaseManager};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    CancellationToken, LyxalWorker, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
};
use lyxal_runtime::RuntimeError;
use lyxal_surreal::ToSql;
use std::collections::VecDeque;
use std::time::{Duration, Instant};
use tokio::sync::Mutex;

use super::{SchedulerEngine, LEADER_KEY};
use crate::error::{SchedulerError, SchedulerResult, SpecError, SpecReason, LEADER_FENCED};
use crate::models::{
    BackfillFireParams, DueBackfill, DueListParams, DueSchedule, FireTime, RunPruneParams,
    RunRescueParams, ScheduleFireParams, ScheduleNextSetParams, SchedulerDatetime,
};
use crate::module::MODULE_ID;
use crate::spec::{draw_jitter, to_datetime, to_signed_duration, to_timestamp, CalendarSet, Spec};

/// Dates remises par appel au moteur SurrealQL (`fire_times`, 1000 au plus).
const FIRE_BATCH: usize = 1000;
/// Planifications et rejeux lus par tour.
const DUE_LIMIT: i64 = 100;

/// Rythme du planificateur ; les valeurs par défaut sont celles de W1 et W2, réduites dans les
/// tests.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct LeaderTiming {
    /// Un tour toutes les `tick` (1 s).
    pub tick: Duration,
    /// Durée du bail d'élection (30 s, une seconde au moins).
    pub lease_ttl: Duration,
    /// Renouvellement du bail (10 s).
    pub lease_renew: Duration,
    /// Reprise des baux d'exécution expirés (30 s).
    pub rescue_every: Duration,
    /// Élagage de l'historique (1 h).
    pub prune_every: Duration,
}

impl Default for LeaderTiming {
    fn default() -> Self {
        Self {
            tick: Duration::from_secs(1),
            lease_ttl: Duration::from_secs(30),
            lease_renew: Duration::from_secs(10),
            rescue_every: Duration::from_secs(30),
            prune_every: Duration::from_secs(3600),
        }
    }
}

/// Bilan d'un tour du planificateur.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct LeaderReport {
    /// Vrai si ce nœud tenait le bail pendant le tour.
    pub leader: bool,
    /// Exécutions créées par les échéances.
    pub fired: u64,
    /// Exécutions créées par les rejeux.
    pub backfilled: u64,
    /// Échéances ignorées parce que la limite d'exécutions en attente d'une organisation est
    /// atteinte (`max_pending_runs`, A4).
    pub limited: u64,
    /// Planifications déclarées invalides.
    pub invalid: u64,
    /// Exécutions reprises après l'expiration de leur bail.
    pub rescued: u64,
    /// Exécutions élaguées.
    pub pruned: u64,
    /// Éléments en échec, laissés pour le tour suivant.
    pub failed: u64,
}

/// Marge avant la création d'une planification jamais traitée dans laquelle une date échue est
/// encore rattrapée (latence entre le calcul d'une date unique et son écriture).
const CREATION_GRACE: SignedDuration = SignedDuration::from_secs(5);

/// État du planificateur entre deux tours.
#[derive(Default)]
struct LeaderState {
    lease: Option<LeaderLease>,
    renewed: Option<Instant>,
    rescued: Option<Instant>,
    pruned: Option<Instant>,
}

/// Garde de génération remise à chaque écriture du planificateur : nœud et génération du bail
/// détenu pour ce tour (Y2).
#[derive(Debug, Clone)]
struct Fence {
    node: String,
    generation: i64,
}

impl Fence {
    fn of(lease: &LeaderLease) -> Self {
        Self {
            node: lease.owner.as_str().to_string(),
            generation: i64::try_from(lease.generation).unwrap_or(i64::MAX),
        }
    }
}

/// Worker planificateur.
pub struct SchedulerLeaderWorker {
    descriptor: WorkerDescriptor,
    engine: SchedulerEngine,
    leases: SurrealLeaderLeaseManager,
    timing: LeaderTiming,
    state: Mutex<LeaderState>,
}

/// Calcul des dates d'une planification due, à l'instant `now` : prochaine échéance après
/// maintenant, dates manquées de `[next_fire_at, now]` dans la fenêtre de rattrapage (aucune
/// politique n'exécute une date plus ancienne ; les 1000 dernières au plus) et décalage
/// aléatoire maximal.
fn plan(
    due: &DueSchedule,
    now: Timestamp,
) -> Result<(Option<SchedulerDatetime>, Vec<Timestamp>, SignedDuration), SpecError> {
    let created = to_timestamp("created_at", &due.created_at)?;
    let spec = Spec::parse(
        &due.spec,
        created,
        CalendarSet::from_calendars(&due.calendars)?,
    )?;
    // U1 et U5 contrôlés par le moteur aussi : des règles écrites directement en SurrealQL ne
    // passent pas par le contrôle de l'écriture (`SchedulerService`)
    spec.check_rhythm(now)?;
    let next = spec.next_after(now)?.map(to_datetime).transpose()?;
    let window = to_signed_duration("catchup_window", &due.catchup_window)?;
    let out_of_range =
        |rule: &str, e: jiff::Error| SpecError::new(rule, SpecReason::OutOfRange, e.to_string());
    let earliest = now
        .checked_sub(window)
        .map_err(|e| out_of_range("catchup_window", e))?;
    // Borne basse des dates manquées : la prochaine échéance connue (incluse) ; pour une
    // planification jamais traitée (ni prochaine échéance ni échéance passée), sa création moins
    // une marge (`CREATION_GRACE` : une date unique demandée juste avant une écriture lente peut
    // précéder l'heure de création enregistrée par la base), afin que les dates échues avant le premier tour du planificateur suivent la
    // politique de rattrapage. Une planification déjà exécutée dont la prochaine échéance est à
    // recalculer (modification, reprise après pause) ne rattrape rien.
    let from = match (&due.next_fire_at, &due.last_fire_at) {
        (Some(next_fire_at), _) => to_timestamp("next_fire_at", next_fire_at)?
            .max(earliest)
            .checked_sub(SignedDuration::from_nanos(1))
            .map_err(|e| out_of_range("next_fire_at", e))?,
        (None, None) => created
            .checked_sub(CREATION_GRACE)
            .map_err(|e| out_of_range("created_at", e))?
            .max(earliest),
        (None, Some(_)) => return Ok((next, Vec::new(), SignedDuration::ZERO)),
    };
    let mut times: VecDeque<Timestamp> = VecDeque::new();
    let mut cursor = from;
    loop {
        let batch = spec.fire_times_between(cursor, now, FIRE_BATCH)?;
        for t in &batch.times {
            if times.len() == FIRE_BATCH {
                times.pop_front();
            }
            times.push_back(*t);
        }
        match (batch.truncated, batch.times.last()) {
            (true, Some(last)) => cursor = *last,
            _ => break,
        }
    }
    Ok((next, times.into(), spec.max_jitter(now)?))
}

impl SchedulerLeaderWorker {
    /// Planificateur du moteur `engine`, sous les baux d'élection de `leases` (session système).
    pub fn new(
        engine: SchedulerEngine,
        leases: SurrealLeaderLeaseManager,
    ) -> Result<Self, RuntimeError> {
        Self::with_timing(engine, leases, LeaderTiming::default())
    }

    /// Planificateur au rythme `timing` (tests).
    pub fn with_timing(
        engine: SchedulerEngine,
        leases: SurrealLeaderLeaseManager,
        timing: LeaderTiming,
    ) -> Result<Self, RuntimeError> {
        let module_id = ModuleId::new(MODULE_ID);
        let mut descriptor = WorkerDescriptor::new(
            WorkerId::new(&module_id, "leader")?,
            module_id,
            "Lyxal Scheduler Leader",
        );
        descriptor.description = Some(
            "Planificateur élu (bail leader) : échéances, rattrapage, chevauchement, rejeux de période, décalage aléatoire, reprise des baux expirés, élagage"
                .to_string(),
        );
        descriptor.criticality = WorkerCriticality::Required;
        descriptor.shutdown_timeout = Duration::from_secs(10);
        Ok(Self {
            descriptor,
            engine,
            leases,
            timing,
            state: Mutex::new(LeaderState::default()),
        })
    }

    /// Prend ou renouvelle le bail ; vrai si ce nœud le tient pour ce tour.
    async fn hold_lease(&self, state: &mut LeaderState) -> Result<bool, RuntimeError> {
        let node = self.engine.node();
        if let Some(lease) = state.lease.clone() {
            let due = state
                .renewed
                .is_none_or(|at| at.elapsed() >= self.timing.lease_renew);
            if !due {
                return Ok(true);
            }
            match self.leases.renew(&lease, self.timing.lease_ttl).await? {
                Some(renewed) => {
                    state.lease = Some(renewed);
                    state.renewed = Some(Instant::now());
                    return Ok(true);
                }
                None => {
                    tracing::warn!(node = %node, generation = lease.generation, "bail du planificateur perdu : la planification s'arrête sur ce nœud");
                    state.lease = None;
                    state.renewed = None;
                }
            }
        }
        let acquired = self
            .leases
            .acquire(LEADER_KEY, node, self.timing.lease_ttl)
            .await?;
        match acquired.lease() {
            Some(lease) => {
                if !matches!(acquired, AcquireLeaderLeaseResult::AlreadyOwned(_)) {
                    tracing::info!(node = %node, generation = lease.generation, "bail du planificateur pris : ce nœud planifie");
                }
                state.lease = Some(lease.clone());
                state.renewed = Some(Instant::now());
                Ok(true)
            }
            None => Ok(false),
        }
    }

    /// Un tour : bail, puis, si ce nœud le tient, échéances, rejeux, reprise et élagage.
    pub async fn run_once(
        &self,
        cancellation: &CancellationToken,
    ) -> SchedulerResult<LeaderReport> {
        let mut state = self.state.lock().await;
        let mut report = LeaderReport::default();
        match self.hold_lease(&mut state).await {
            Ok(true) => report.leader = true,
            Ok(false) => return Ok(report),
            Err(error) => {
                tracing::warn!(error = %error, "bail du planificateur illisible : aucun tour");
                return Ok(report);
            }
        }
        let Some(fence) = state.lease.as_ref().map(Fence::of) else {
            return Ok(report);
        };
        let outcome = self
            .tour(&fence, &mut state, cancellation, &mut report)
            .await;
        match outcome {
            Err(error) if error.is_code(LEADER_FENCED) => {
                // Bail perdu au milieu du tour (autre nœud, autre génération, bail expiré) : ce
                // nœud l'oublie et ne planifie plus ; il tentera de le reprendre au tour suivant
                tracing::warn!(node = %fence.node, generation = fence.generation, "bail du planificateur perdu pendant le tour : écritures refusées, la planification s'arrête sur ce nœud");
                state.lease = None;
                state.renewed = None;
                report.leader = false;
                Ok(report)
            }
            Err(error) => Err(error),
            Ok(()) => Ok(report),
        }
    }

    /// Corps d'un tour sous la garde `fence` : échéances, rejeux, reprise et élagage. Une
    /// écriture refusée pour bail perdu (`SCHEDULER_LEADER_FENCED`) arrête le tour.
    async fn tour(
        &self,
        fence: &Fence,
        state: &mut LeaderState,
        cancellation: &CancellationToken,
        report: &mut LeaderReport,
    ) -> SchedulerResult<()> {
        let due = self
            .engine
            .store()
            .due_list(DueListParams {
                limit: Some(DUE_LIMIT),
                language: None,
            })
            .await?;
        let now = to_timestamp("now", &due.now)?;
        for schedule in &due.schedules {
            if cancellation.is_cancelled() {
                return Ok(());
            }
            if let Err(error) = self.fire(fence, schedule, now, report).await {
                if error.is_code(LEADER_FENCED) {
                    return Err(error);
                }
                report.failed += 1;
                tracing::warn!(schedule = %schedule.id.to_sql(), code = %error.code(), error = %error, "échéances non traitées");
            }
        }
        for backfill in &due.backfills {
            if cancellation.is_cancelled() {
                return Ok(());
            }
            if let Err(error) = self.backfill(fence, backfill, cancellation, report).await {
                if error.is_code(LEADER_FENCED) {
                    return Err(error);
                }
                report.failed += 1;
                tracing::warn!(backfill = %backfill.id.to_sql(), code = %error.code(), error = %error, "rejeu non traité");
            }
        }

        if state
            .rescued
            .is_none_or(|at| at.elapsed() >= self.timing.rescue_every)
        {
            state.rescued = Some(Instant::now());
            match self
                .engine
                .store()
                .run_rescue(RunRescueParams {
                    node: fence.node.clone(),
                    generation: fence.generation,
                    limit: None,
                    language: None,
                })
                .await
            {
                Ok(rescue) => {
                    report.rescued += u64::try_from(rescue.rescued.len()).unwrap_or(0);
                    if rescue.reconciled > 0 {
                        tracing::warn!(
                            reconciled = rescue.reconciled,
                            "compteurs de places recalés"
                        );
                    }
                }
                Err(error) => {
                    let error = SchedulerError::from(error);
                    if error.is_code(LEADER_FENCED) {
                        return Err(error);
                    }
                    report.failed += 1;
                    tracing::warn!(code = %error.code(), error = %error, "reprise des baux expirés impossible");
                }
            }
        }
        if state
            .pruned
            .is_none_or(|at| at.elapsed() >= self.timing.prune_every)
        {
            state.pruned = Some(Instant::now());
            match self
                .engine
                .store()
                .run_prune(RunPruneParams {
                    node: fence.node.clone(),
                    generation: fence.generation,
                    limit: None,
                    language: None,
                })
                .await
            {
                Ok(pruned) => report.pruned += u64::try_from(pruned.deleted).unwrap_or(0),
                Err(error) => {
                    let error = SchedulerError::from(error);
                    if error.is_code(LEADER_FENCED) {
                        return Err(error);
                    }
                    report.failed += 1;
                    tracing::warn!(code = %error.code(), error = %error, "élagage impossible");
                }
            }
        }
        Ok(())
    }

    /// Échéances d'une planification due ; une planification dont les règles ne se lisent plus
    /// (ou dont aucune date n'est trouvée, U4) est déclarée invalide.
    async fn fire(
        &self,
        fence: &Fence,
        due: &DueSchedule,
        now: Timestamp,
        report: &mut LeaderReport,
    ) -> SchedulerResult<()> {
        let store = self.engine.store();
        let (next, missed, max_jitter) = match plan(due, now) {
            Ok(plan) => plan,
            Err(error) => return self.invalidate(fence, due, error, report).await,
        };

        if due.next_fire_at.is_none() && missed.is_empty() {
            // Prochaine date à calculer (création, règles modifiées, reprise) ; aucune : la
            // planification est terminée par un appel sans échéance. Une planification jamais
            // traitée dont des dates sont déjà échues passe par le tir ci-dessous (rattrapage)
            match next {
                Some(next) => {
                    store
                        .schedule_next_set(ScheduleNextSetParams {
                            node: fence.node.clone(),
                            generation: fence.generation,
                            schedule: due.id.clone(),
                            next_fire_at: Some(next),
                            invalid_reason: None,
                            language: None,
                        })
                        .await?;
                }
                None => {
                    store
                        .schedule_fire(ScheduleFireParams {
                            node: fence.node.clone(),
                            generation: fence.generation,
                            schedule: due.id.clone(),
                            fire_times: Vec::new(),
                            next_fire_at: None,
                            language: None,
                        })
                        .await?;
                }
            }
            return Ok(());
        }

        // Décalage aléatoire (U5) : seule la date de disponibilité est décalée
        let mut fire_times = Vec::with_capacity(missed.len());
        for t in missed {
            let jitter = draw_jitter(max_jitter)
                .map_err(|e| SpecError::new("jitter", SpecReason::Jitter, e.to_string()))?;
            let available = t.checked_add(jitter).unwrap_or(t);
            fire_times.push(FireTime {
                at: to_datetime(t)?,
                available_at: to_datetime(available)?,
            });
        }
        let fired = store
            .schedule_fire(ScheduleFireParams {
                node: fence.node.clone(),
                generation: fence.generation,
                schedule: due.id.clone(),
                fire_times,
                next_fire_at: next,
                language: None,
            })
            .await?;
        report.fired += u64::try_from(fired.runs.len()).unwrap_or(0);
        if fired.limited > 0 {
            report.limited += u64::try_from(fired.limited).unwrap_or(0);
            tracing::warn!(schedule = %due.id.to_sql(), limited = fired.limited, "limite d'exécutions en attente atteinte : échéances ignorées");
        }
        Ok(())
    }

    async fn invalidate(
        &self,
        fence: &Fence,
        due: &DueSchedule,
        error: SpecError,
        report: &mut LeaderReport,
    ) -> SchedulerResult<()> {
        tracing::warn!(schedule = %due.id.to_sql(), reason = %error.reason, rule = %error.rule, "règles de dates refusées : planification invalide");
        self.engine
            .store()
            .schedule_next_set(ScheduleNextSetParams {
                node: fence.node.clone(),
                generation: fence.generation,
                schedule: due.id.clone(),
                next_fire_at: None,
                invalid_reason: Some(error.invalid_reason()),
                language: None,
            })
            .await?;
        report.invalid += 1;
        Ok(())
    }

    /// Exécutions d'un rejeu de période, par lots de 1000 dates (une date déjà exécutée est
    /// ignorée : un rejeu interrompu reprend du début sans doublon). Règles illisibles : le rejeu
    /// est clos sans exécution. Le bail est revérifié par la base à chaque lot (garde de
    /// génération) : un nœud qui le perd entre deux lots s'arrête au lot suivant.
    async fn backfill(
        &self,
        fence: &Fence,
        due: &DueBackfill,
        cancellation: &CancellationToken,
        report: &mut LeaderReport,
    ) -> SchedulerResult<()> {
        let store = self.engine.store();
        let parsed = to_timestamp("created_at", &due.created_at).and_then(|created| {
            let calendars = CalendarSet::from_calendars(&due.calendars)?;
            Spec::parse(&due.spec, created, calendars)
        });
        let from = to_timestamp("from", &due.from)?;
        let to = to_timestamp("to", &due.to)?;
        let spec = match parsed {
            Ok(spec) => spec,
            Err(error) => {
                tracing::warn!(backfill = %due.id.to_sql(), reason = %error.reason, rule = %error.rule, "règles de dates refusées : rejeu clos sans exécution");
                store
                    .backfill_fire(BackfillFireParams {
                        node: fence.node.clone(),
                        generation: fence.generation,
                        backfill: due.id.clone(),
                        fire_times: Vec::new(),
                        done: Some(true),
                        language: None,
                    })
                    .await?;
                return Ok(());
            }
        };
        let mut cursor = from
            .checked_sub(SignedDuration::from_nanos(1))
            .map_err(|e| SpecError::new("from", SpecReason::OutOfRange, e.to_string()))?;
        loop {
            if cancellation.is_cancelled() {
                return Ok(());
            }
            let batch = spec.fire_times_between(cursor, to, FIRE_BATCH)?;
            let fire_times = batch
                .times
                .iter()
                .map(|t| to_datetime(*t).map(FireTime::at))
                .collect::<Result<Vec<_>, _>>()?;
            let done = !batch.truncated;
            let fired = store
                .backfill_fire(BackfillFireParams {
                    node: fence.node.clone(),
                    generation: fence.generation,
                    backfill: due.id.clone(),
                    fire_times,
                    done: Some(done),
                    language: None,
                })
                .await?;
            report.backfilled += u64::try_from(fired.runs.len()).unwrap_or(0);
            if fired.limited > 0 {
                report.limited += u64::try_from(fired.limited).unwrap_or(0);
                tracing::warn!(backfill = %due.id.to_sql(), limited = fired.limited, "limite d'exécutions en attente atteinte : échéances du rejeu ignorées");
            }
            match (done, batch.times.last()) {
                (false, Some(last)) => cursor = *last,
                _ => return Ok(()),
            }
        }
    }

    /// Libère le bail à l'arrêt, pour qu'un autre nœud planifie sans attendre son échéance.
    async fn release(&self) {
        let mut state = self.state.lock().await;
        if let Some(lease) = state.lease.take() {
            match self.leases.release(&lease).await {
                Ok(true) => {
                    tracing::info!(node = %self.engine.node(), "bail du planificateur libéré")
                }
                Ok(false) => {}
                Err(error) => {
                    tracing::warn!(error = %error, "bail du planificateur non libéré : il expirera")
                }
            }
        }
    }
}

#[async_trait]
impl LyxalWorker for SchedulerLeaderWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        while !ctx.is_cancelled() {
            match self.run_once(&ctx.cancellation).await {
                Ok(report) => {
                    let LeaderReport {
                        fired,
                        backfilled,
                        limited,
                        invalid,
                        rescued,
                        pruned,
                        failed,
                        ..
                    } = report;
                    if fired + backfilled + limited + invalid + rescued + pruned + failed > 0 {
                        tracing::info!(
                            fired,
                            backfilled,
                            limited,
                            invalid,
                            rescued,
                            pruned,
                            failed,
                            "tour du planificateur"
                        );
                    }
                }
                Err(error) => {
                    tracing::warn!(code = %error.code(), error = %error, "tour du planificateur impossible");
                }
            }
            tokio::select! {
                _ = ctx.cancellation.cancelled() => break,
                _ = tokio::time::sleep(self.timing.tick) => {}
            }
        }
        self.release().await;
        Ok(())
    }
}
