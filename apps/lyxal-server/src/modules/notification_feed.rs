//! Temps réel du fil de notifications dans l'application (décisions K6 et F6).
//!
//! L'hôte tient **une** requête `LIVE SELECT` sur `notification_inbox`, ouverte par la session
//! système dans un worker supervisé (`FeedHubWorker`, `LyxalWorker` à annulation coopérative) et
//! relancée après une coupure (erreur ou fin du flux) ; le navigateur ne parle jamais à
//! SurrealDB. Chaque changement est réparti en mémoire (`FeedHub`) vers les seules connexions
//! SSE de la personne concernée (compte et organisation du message) : un nouveau message
//! (événement `notification`), puis ses compteurs (`counts`), relus par
//! `fn::notification_feed_counts` **dans la session de la personne** (aucune donnée du client
//! n'entre dans le calcul). Toutes les minutes, et après chaque reprise de la requête, les
//! compteurs de chaque connexion sont relus : un message en sommeil réapparaît sans worker de
//! réveil. À ce rythme, et sur demande (`FeedHub::probe_live`), le worker vérifie aussi que sa
//! requête est toujours enregistrée par la base (`INFO FOR TABLE`) : une requête supprimée sans
//! que le flux le signale (`KILL`, perte de la connexion) est rouverte. Une personne garde au
//! plus 5 connexions ; une connexion lente (file pleine), dont la
//! session ne permet plus de relire les compteurs, ou à l'arrêt du worker, est fermée : le
//! client se reconnecte et relit son fil.
//!
//! Le flux d'une connexion (route de l'hôte) envoie un signe de vie toutes les 25 s et revérifie
//! alors la session (`FeedTicks`) : session expirée, révoquée ou jeton expiré, le flux se ferme.

use async_trait::async_trait;
use futures::StreamExt;
use lyxal_notification::models::{FeedCounts, FeedCountsParams};
use lyxal_notification::{NotificationError, NotificationStore};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::worker::{
    CancellationToken, LyxalWorker, WorkerContext, WorkerCriticality, WorkerDescriptor, WorkerId,
};
use lyxal_runtime::RuntimeError;
use lyxal_surreal::{RecordId, SurrealValue, ToSql};
use serde_json::Value;
use std::collections::HashMap;
use std::pin::Pin;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex};
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;
use tokio::sync::{broadcast, mpsc};

/// Requête tenue par le hub : de quoi router (compte, organisation) et la vue d'un nouveau
/// message, projetée par la base (`fn::notification_feed_view`, même vue que
/// `fn::notification_feed_list`).
const LIVE_QUERY: &str =
    "LIVE SELECT id, identity, tenant, fn::notification_feed_view($this) AS view FROM notification_inbox";

/// Réglages du temps réel du fil.
#[derive(Debug, Clone)]
pub struct FeedSettings {
    /// Connexions au plus par personne (5).
    pub max_connections: usize,
    /// Signe de vie et contrôle de la session de chaque connexion (25 s).
    pub keep_alive: Duration,
    /// Relecture des compteurs de toutes les connexions (1 min : fin des sommeils).
    pub counts_interval: Duration,
    /// Attente avant de rouvrir la requête `LIVE SELECT` après une coupure.
    pub reconnect_delay: Duration,
    /// Événements en attente au plus par connexion (au-delà, la connexion est fermée).
    pub buffer: usize,
}

impl Default for FeedSettings {
    fn default() -> Self {
        Self {
            max_connections: 5,
            keep_alive: Duration::from_secs(25),
            counts_interval: Duration::from_secs(60),
            reconnect_delay: Duration::from_secs(2),
            buffer: 64,
        }
    }
}

/// Événement envoyé à une connexion.
#[derive(Debug, Clone, PartialEq)]
pub enum FeedEvent {
    /// Nouveau message du fil (vue de `fn::notification_feed_view`).
    Notification(Value),
    /// Compteurs du fil (non vus, non lus, total).
    Counts(FeedCounts),
}

/// Rythme des signes de vie : intervalle réel, ou impulsions données par les tests (aucune
/// attente liée à l'horloge).
#[derive(Clone)]
enum Ticks {
    Interval(Duration),
    Manual(broadcast::Sender<()>),
}

/// Impulsions des signes de vie (tests) : chaque `tick` fait envoyer un signe de vie à chaque
/// connexion, qui revérifie alors sa session.
#[derive(Clone)]
pub struct FeedTicks(broadcast::Sender<()>);

impl FeedTicks {
    /// Une impulsion pour toutes les connexions ouvertes.
    pub fn tick(&self) {
        // Aucune connexion à l'écoute : rien à faire
        let _ = self.0.send(());
    }
}

/// Flux des signes de vie d'une connexion.
pub type TickStream = Pin<Box<dyn futures::Stream<Item = ()> + Send>>;

/// Connexion visée par un envoi : identifiant, file et session de la personne.
type Target = (u64, mpsc::Sender<FeedEvent>, NotificationStore);

struct Connection {
    id: u64,
    tenant: Option<String>,
    sender: mpsc::Sender<FeedEvent>,
    store: NotificationStore,
}

struct HubInner {
    settings: FeedSettings,
    ticks: Ticks,
    /// Connexions par compte (`auth_identity:<clé>`).
    connections: Mutex<HashMap<String, Vec<Connection>>>,
    next_id: AtomicU64,
    /// Reprises réussies de la requête `LIVE SELECT` (observation, tests).
    generation: AtomicU64,
    /// Identifiant de la requête `LIVE SELECT` en cours (observation, tests).
    live_query: Mutex<Option<String>>,
    /// Annulé à l'arrêt du worker : tous les flux se ferment.
    closed: CancellationToken,
    /// Demande de contrôle immédiat de la requête `LIVE SELECT`.
    probe: tokio::sync::Notify,
}

/// Répartition en mémoire des changements du fil vers les connexions SSE.
#[derive(Clone)]
pub struct FeedHub {
    inner: Arc<HubInner>,
}

/// Connexion SSE enregistrée ; retirée du hub quand elle est abandonnée (client parti, flux
/// fermé).
pub struct FeedConnection {
    hub: FeedHub,
    identity: String,
    id: u64,
    receiver: mpsc::Receiver<FeedEvent>,
    closed: CancellationToken,
}

impl FeedConnection {
    /// Prochain événement ; `None` quand le hub a fermé la connexion.
    pub async fn recv(&mut self) -> Option<FeedEvent> {
        tokio::select! {
            _ = self.closed.cancelled() => None,
            event = self.receiver.recv() => event,
        }
    }
}

impl Drop for FeedConnection {
    fn drop(&mut self) {
        self.hub.unregister(&self.identity, self.id);
    }
}

impl FeedHub {
    /// Hub aux signes de vie réguliers (`settings.keep_alive`).
    pub fn new(settings: FeedSettings) -> Self {
        let ticks = Ticks::Interval(settings.keep_alive);
        Self::build(settings, ticks)
    }

    /// Hub dont les signes de vie sont donnés à la main (tests) : aucun délai réel.
    pub fn with_manual_ticks(settings: FeedSettings) -> (Self, FeedTicks) {
        let (sender, _) = broadcast::channel(16);
        let hub = Self::build(settings, Ticks::Manual(sender.clone()));
        (hub, FeedTicks(sender))
    }

    fn build(settings: FeedSettings, ticks: Ticks) -> Self {
        Self {
            inner: Arc::new(HubInner {
                settings,
                ticks,
                connections: Mutex::new(HashMap::new()),
                next_id: AtomicU64::new(1),
                generation: AtomicU64::new(0),
                live_query: Mutex::new(None),
                closed: CancellationToken::new(),
                probe: tokio::sync::Notify::new(),
            }),
        }
    }

    /// Réglages.
    pub fn settings(&self) -> &FeedSettings {
        &self.inner.settings
    }

    /// Reprises réussies de la requête `LIVE SELECT` depuis le démarrage.
    pub fn generation(&self) -> u64 {
        self.inner.generation.load(Ordering::SeqCst)
    }

    /// Identifiant (UUID) de la requête `LIVE SELECT` en cours, s'il y en a une.
    pub fn live_query(&self) -> Option<String> {
        self.inner
            .live_query
            .lock()
            .unwrap_or_else(std::sync::PoisonError::into_inner)
            .clone()
    }

    fn set_live_query(&self, id: Option<String>) {
        *self
            .inner
            .live_query
            .lock()
            .unwrap_or_else(std::sync::PoisonError::into_inner) = id;
    }

    /// Connexions ouvertes d'une personne (compte `auth_identity:<clé>`).
    pub fn connections_of(&self, identity: &str) -> usize {
        self.lock().get(identity).map_or(0, Vec::len)
    }

    /// Vrai une fois le hub fermé (arrêt du worker).
    pub fn is_closed(&self) -> bool {
        self.inner.closed.is_cancelled()
    }

    fn lock(&self) -> std::sync::MutexGuard<'_, HashMap<String, Vec<Connection>>> {
        // Un verrou empoisonné ne contient que des connexions : il reste utilisable
        self.inner
            .connections
            .lock()
            .unwrap_or_else(std::sync::PoisonError::into_inner)
    }

    /// Enregistre une connexion de la personne `identity` dans l'organisation `tenant`, avec
    /// sa session (`store`) pour relire ses compteurs ; refusée au-delà de 5 connexions
    /// (`NOTIFICATION_FEED_STREAM_LIMIT`) ou après la fermeture du hub.
    pub fn register(
        &self,
        identity: String,
        tenant: Option<String>,
        store: NotificationStore,
    ) -> Result<FeedConnection, NotificationError> {
        if self.is_closed() {
            return Err(NotificationError::Configuration(
                "temps réel du fil arrêté".to_string(),
            ));
        }
        let (sender, receiver) = mpsc::channel(self.inner.settings.buffer.max(1));
        let id = self.inner.next_id.fetch_add(1, Ordering::SeqCst);
        {
            let mut connections = self.lock();
            let mine = connections.entry(identity.clone()).or_default();
            if mine.len() >= self.inner.settings.max_connections {
                return Err(NotificationError::Refused("NOTIFICATION_FEED_STREAM_LIMIT"));
            }
            mine.push(Connection {
                id,
                tenant,
                sender,
                store,
            });
        }
        Ok(FeedConnection {
            hub: self.clone(),
            identity,
            id,
            receiver,
            closed: self.inner.closed.child_token(),
        })
    }

    fn unregister(&self, identity: &str, id: u64) {
        let mut connections = self.lock();
        if let Some(mine) = connections.get_mut(identity) {
            mine.retain(|connection| connection.id != id);
            if mine.is_empty() {
                connections.remove(identity);
            }
        }
    }

    /// Signes de vie d'une connexion.
    pub fn ticks(&self) -> TickStream {
        match &self.inner.ticks {
            Ticks::Interval(period) => {
                let mut interval =
                    tokio::time::interval_at(tokio::time::Instant::now() + *period, *period);
                interval.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Delay);
                Box::pin(futures::stream::unfold(
                    interval,
                    |mut interval| async move {
                        interval.tick().await;
                        Some(((), interval))
                    },
                ))
            }
            Ticks::Manual(sender) => Box::pin(futures::stream::unfold(
                sender.subscribe(),
                |mut receiver| async move {
                    loop {
                        match receiver.recv().await {
                            Ok(()) => return Some(((), receiver)),
                            Err(broadcast::error::RecvError::Lagged(_)) => continue,
                            Err(broadcast::error::RecvError::Closed) => return None,
                        }
                    }
                },
            )),
        }
    }

    /// Demande au worker de vérifier tout de suite que sa requête `LIVE SELECT` est toujours
    /// enregistrée par la base (sinon il la rouvre).
    pub fn probe_live(&self) {
        self.inner.probe.notify_one();
    }

    /// Ferme toutes les connexions (arrêt du worker).
    pub fn close_all(&self) {
        self.inner.closed.cancel();
        self.lock().clear();
    }

    /// Connexions d'une personne dans une organisation (copies : aucun verrou tenu pendant les
    /// appels à la base).
    fn targets(&self, identity: &str, tenant: Option<&str>) -> Vec<Target> {
        self.lock()
            .get(identity)
            .map(|mine| {
                mine.iter()
                    .filter(|connection| connection.tenant.as_deref() == tenant)
                    .map(|c| (c.id, c.sender.clone(), c.store.clone()))
                    .collect()
            })
            .unwrap_or_default()
    }

    /// Envoie un événement ; une connexion dont la file est pleine ou fermée est retirée.
    fn send(&self, identity: &str, id: u64, sender: &mpsc::Sender<FeedEvent>, event: FeedEvent) {
        if sender.try_send(event).is_err() {
            tracing::info!(
                connection = id,
                "connexion du fil fermée : file pleine ou client parti"
            );
            self.unregister(identity, id);
        }
    }

    /// Compteurs relus dans la session de la personne de chaque connexion visée ; une session
    /// qui ne le permet plus ferme sa connexion.
    async fn push_counts(&self, identity: &str, targets: Vec<Target>) {
        for (id, sender, store) in targets {
            match store.feed_counts(FeedCountsParams::default()).await {
                Ok(counts) => self.send(identity, id, &sender, FeedEvent::Counts(counts)),
                Err(error) => {
                    let error = NotificationError::from(error);
                    if error.code() == "NOTIFICATION_FEED_NO_ACCOUNT" {
                        // Personne connectée sans abonné dans cette organisation : fil vide
                        self.send(
                            identity,
                            id,
                            &sender,
                            FeedEvent::Counts(FeedCounts::default()),
                        );
                    } else {
                        tracing::info!(connection = id, code = %error.code(), "compteurs du fil illisibles : connexion fermée");
                        self.unregister(identity, id);
                    }
                }
            }
        }
    }

    /// Relit les compteurs de toutes les connexions (toutes les minutes, après une reprise).
    pub async fn push_counts_all(&self) {
        let all: Vec<(String, Vec<Target>)> = self
            .lock()
            .iter()
            .map(|(identity, mine)| {
                (
                    identity.clone(),
                    mine.iter()
                        .map(|c| (c.id, c.sender.clone(), c.store.clone()))
                        .collect(),
                )
            })
            .collect();
        for (identity, targets) in all {
            self.push_counts(&identity, targets).await;
        }
    }

    /// Répartit un changement du fil : nouveau message puis compteurs, aux seules connexions de
    /// sa personne dans son organisation.
    pub async fn dispatch(&self, change: InboxChange, created: bool) {
        let identity = change.identity.to_sql();
        let tenant = change.tenant.as_ref().map(ToSql::to_sql);
        let targets = self.targets(&identity, tenant.as_deref());
        if targets.is_empty() {
            return;
        }
        if created {
            if let Some(view) = change.view {
                let view = view.into_value().into_json_value();
                for (id, sender, _) in &targets {
                    self.send(
                        &identity,
                        *id,
                        sender,
                        FeedEvent::Notification(view.clone()),
                    );
                }
            }
        }
        self.push_counts(&identity, targets).await;
    }
}

/// Changement reçu de la requête `LIVE SELECT` : compte et organisation du message, et sa vue.
#[derive(Debug, Clone, SurrealValue)]
pub struct InboxChange {
    /// Message.
    pub id: RecordId,
    /// Compte de la personne.
    pub identity: RecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<RecordId>,
    /// Vue du message (`fn::notification_feed_view`).
    #[surreal(default)]
    pub view: Option<surrealdb::types::Value>,
}

/// Worker supervisé qui tient la requête `LIVE SELECT` du fil (session système) et alimente le
/// hub ; il la rouvre après une coupure et ferme toutes les connexions à son arrêt.
pub struct FeedHubWorker {
    descriptor: WorkerDescriptor,
    hub: FeedHub,
    client: Surreal<Any>,
}

impl FeedHubWorker {
    /// Worker sur la session système de l'hôte.
    pub fn new(hub: FeedHub, client: Surreal<Any>) -> Result<Self, RuntimeError> {
        let module_id = ModuleId::new(lyxal_notification::MODULE_ID);
        let mut descriptor = WorkerDescriptor::new(
            WorkerId::new(&module_id, "feed_hub")?,
            module_id,
            "Lyxal Notification Feed Hub",
        );
        descriptor.description = Some(
            "Temps réel du fil dans l'application : requête LIVE SELECT répartie vers les flux SSE"
                .to_string(),
        );
        descriptor.criticality = WorkerCriticality::Optional;
        descriptor.shutdown_timeout = Duration::from_secs(10);
        Ok(Self {
            descriptor,
            hub,
            client,
        })
    }

    /// Ouvre la requête `LIVE SELECT` du fil ; renvoie son flux et son identifiant.
    async fn open(
        &self,
    ) -> Result<
        (
            surrealdb::method::QueryStream<surrealdb::Notification<InboxChange>>,
            Option<String>,
        ),
        surrealdb::Error,
    > {
        let mut response = self.client.query(LIVE_QUERY).await?;
        let stream = response.stream::<surrealdb::Notification<InboxChange>>(0)?;
        let id: Option<surrealdb::types::Uuid> = response.take(0)?;
        Ok((stream, id.map(|id| id.to_string())))
    }

    /// Vrai si la base tient toujours la requête `id` (`lives` de `INFO FOR TABLE`) ; une erreur
    /// de lecture est rendue (la requête est alors rouverte).
    async fn alive(&self, id: Option<&str>) -> Result<bool, surrealdb::Error> {
        let Some(id) = id else {
            return Ok(false);
        };
        let mut response = self
            .client
            .query("INFO FOR TABLE notification_inbox")
            .await?;
        let info: Option<surrealdb::types::Value> = response.take(0)?;
        let info = info.map(surrealdb::types::Value::into_json_value);
        Ok(info
            .as_ref()
            .and_then(|info| info.get("lives"))
            .and_then(Value::as_object)
            .is_some_and(|lives| lives.contains_key(id)))
    }

    /// Contrôle de la requête en cours ; faux s'il faut la rouvrir.
    async fn keep(&self, id: Option<&str>) -> bool {
        match self.alive(id).await {
            Ok(true) => true,
            Ok(false) => {
                tracing::warn!("requête LIVE du fil supprimée par la base : reprise");
                false
            }
            Err(error) => {
                tracing::warn!(error = %error, "requête LIVE du fil invérifiable : reprise");
                false
            }
        }
    }

    /// Travail sur la base mis en course avec l'annulation : `None` si le worker est annulé
    /// avant la fin (une base bloquée ne retarde jamais l'arrêt).
    async fn until_cancelled<F: std::future::Future>(
        ctx: &WorkerContext,
        work: F,
    ) -> Option<F::Output> {
        race_cancellation(&ctx.cancellation, work).await
    }

    /// Attente avant une reprise ; vrai si le worker est annulé entre-temps.
    async fn pause(&self, ctx: &WorkerContext) -> bool {
        tokio::select! {
            _ = ctx.cancellation.cancelled() => true,
            _ = tokio::time::sleep(self.hub.settings().reconnect_delay) => false,
        }
    }
}

#[async_trait]
impl LyxalWorker for FeedHubWorker {
    fn descriptor(&self) -> &WorkerDescriptor {
        &self.descriptor
    }

    async fn run(&self, ctx: WorkerContext) -> Result<(), RuntimeError> {
        // Flux fermés à la sortie, même si la tâche est interrompue de force par le superviseur
        let _close = CloseOnDrop(&self.hub);
        let period = self.hub.settings().counts_interval;
        let mut counts = tokio::time::interval_at(tokio::time::Instant::now() + period, period);
        counts.set_missed_tick_behavior(tokio::time::MissedTickBehavior::Delay);
        'live: while !ctx.is_cancelled() {
            let Some(opened) = Self::until_cancelled(&ctx, self.open()).await else {
                break;
            };
            let (mut stream, id) = match opened {
                Ok((stream, id)) => {
                    self.hub.set_live_query(id.clone());
                    (stream, id)
                }
                Err(error) => {
                    tracing::warn!(error = %error, "requête LIVE du fil impossible : nouvel essai");
                    if self.pause(&ctx).await {
                        break;
                    }
                    continue;
                }
            };
            self.hub.inner.generation.fetch_add(1, Ordering::SeqCst);
            // Changements perdus pendant la coupure : compteurs relus pour tous
            if Self::until_cancelled(&ctx, self.hub.push_counts_all())
                .await
                .is_none()
            {
                break;
            }
            loop {
                tokio::select! {
                    _ = ctx.cancellation.cancelled() => break 'live,
                    _ = counts.tick() => {
                        match Self::until_cancelled(&ctx, self.keep(id.as_deref())).await {
                            None => break 'live,
                            Some(false) => break,
                            Some(true) => {}
                        }
                        if Self::until_cancelled(&ctx, self.hub.push_counts_all()).await.is_none() {
                            break 'live;
                        }
                    }
                    _ = self.hub.inner.probe.notified() => {
                        match Self::until_cancelled(&ctx, self.keep(id.as_deref())).await {
                            None => break 'live,
                            Some(false) => break,
                            Some(true) => {}
                        }
                    }
                    next = stream.next() => match next {
                        Some(Ok(notification)) => {
                            let created = matches!(notification.action, surrealdb::types::Action::Create);
                            if Self::until_cancelled(&ctx, self.hub.dispatch(notification.data, created)).await.is_none() {
                                break 'live;
                            }
                        }
                        Some(Err(error)) => {
                            tracing::warn!(error = %error, "requête LIVE du fil en erreur : reprise");
                            break;
                        }
                        None => {
                            tracing::warn!("requête LIVE du fil terminée : reprise");
                            break;
                        }
                    },
                }
            }
            drop(stream);
            self.hub.set_live_query(None);
            if self.pause(&ctx).await {
                break;
            }
        }
        self.hub.set_live_query(None);
        Ok(())
    }
}

/// `work` mis en course avec `cancellation` : `None` si l'annulation arrive d'abord.
async fn race_cancellation<F: std::future::Future>(
    cancellation: &CancellationToken,
    work: F,
) -> Option<F::Output> {
    tokio::select! {
        _ = cancellation.cancelled() => None,
        output = work => Some(output),
    }
}

/// Ferme tous les flux du fil quand le worker s'arrête, normalement ou interrompu de force
/// (la tâche abandonnée par le superviseur libère ce garde).
struct CloseOnDrop<'a>(&'a FeedHub);

impl Drop for CloseOnDrop<'_> {
    fn drop(&mut self) {
        self.0.close_all();
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn a_stalled_database_wait_gives_way_to_cancellation() {
        let cancellation = CancellationToken::new();
        cancellation.cancel();
        // Une attente qui ne finit jamais (base bloquée) ne retarde pas l'arrêt
        let outcome = race_cancellation(&cancellation, std::future::pending::<()>()).await;
        assert!(outcome.is_none());
        let live = CancellationToken::new();
        assert_eq!(race_cancellation(&live, async { 7 }).await, Some(7));
    }

    #[tokio::test]
    async fn a_forcibly_aborted_worker_still_closes_the_hub() {
        let hub = FeedHub::new(FeedSettings::default());
        let held = hub.clone();
        let task = tokio::spawn(async move {
            let _close = CloseOnDrop(&held);
            std::future::pending::<()>().await;
        });
        tokio::task::yield_now().await;
        assert!(!hub.is_closed());
        // Le superviseur abandonne la tâche après son délai d'arrêt : le garde ferme le hub
        task.abort();
        assert!(task.await.is_err());
        assert!(hub.is_closed());
    }
}
