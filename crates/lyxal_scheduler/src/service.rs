//! Service du planificateur : contrôle des règles de dates d'une planification avant son
//! écriture (`fn::scheduler_schedule_create` et `_update` ne savent pas lire une expression cron
//! ni un fuseau), et prévision des prochaines échéances pour l'affichage.

use jiff::Timestamp;

use crate::error::{SchedulerResult, SpecError};
use crate::models::{
    CalendarRefParams, CalendarRule, Schedule, ScheduleCreateParams, ScheduleRefParams,
    ScheduleSpec, ScheduleUpdateParams, SchedulerDatetime, SchedulerRecordId,
};
use crate::spec::{to_datetime, to_timestamp, CalendarSet, Spec};
use crate::store::SchedulerStore;

/// Échéance prévue d'une planification.
#[derive(Debug, Clone, PartialEq)]
pub struct ForecastEntry {
    /// Date (UTC).
    pub fire_at: SchedulerDatetime,
    /// Heure locale dans le fuseau de la planification (RFC 9557,
    /// `2026-03-29T03:00:00+02:00[Europe/Paris]`).
    pub local: String,
}

/// Service du planificateur sur un store (session SurrealDB de l'appelant).
#[derive(Clone)]
pub struct SchedulerService {
    store: SchedulerStore,
}

impl SchedulerService {
    /// Service sur le store `store`.
    pub fn new(store: SchedulerStore) -> Self {
        Self { store }
    }

    /// Store sous-jacent.
    pub fn store(&self) -> &SchedulerStore {
        &self.store
    }

    /// Règles des calendriers `ids`, lues avec les droits de l'appelant (un calendrier absent ou
    /// illisible : `SCHEDULER_CALENDAR_NOT_FOUND`).
    async fn calendar_set(&self, ids: &[SchedulerRecordId]) -> SchedulerResult<CalendarSet> {
        let mut rules: Vec<Vec<CalendarRule>> = Vec::with_capacity(ids.len());
        for id in ids {
            let calendar = self
                .store
                .calendar_get(CalendarRefParams {
                    calendar: id.clone(),
                    language: None,
                })
                .await?;
            rules.push(calendar.rules);
        }
        let slices: Vec<&[CalendarRule]> = rules.iter().map(Vec::as_slice).collect();
        Ok(CalendarSet::parse(&slices)?)
    }

    /// Contrôle des règles `spec` d'une planification créée à `created_at` avec les calendriers
    /// `calendars`, sans écriture : syntaxe des expressions, fuseau IANA, au moins une échéance
    /// future, écart d'au moins une minute (U1), décalage (U5), règles des calendriers.
    /// Erreur `SCHEDULER_SPEC_INVALID` avec la règle fautive.
    pub async fn validate_spec(
        &self,
        spec: &ScheduleSpec,
        calendars: &[SchedulerRecordId],
        created_at: Option<&SchedulerDatetime>,
    ) -> SchedulerResult<Spec> {
        let calendars = self.calendar_set(calendars).await?;
        let now = Timestamp::now();
        let created_at = match created_at {
            Some(value) => to_timestamp("created_at", value)?,
            None => now,
        };
        let parsed = Spec::parse(spec, created_at, calendars)?;
        parsed.validate(now)?;
        Ok(parsed)
    }

    /// Contrôle puis crée une planification (`fn::scheduler_schedule_create`).
    pub async fn schedule_create(&self, params: ScheduleCreateParams) -> SchedulerResult<Schedule> {
        let calendars = params.calendars.clone().unwrap_or_default();
        self.validate_spec(&params.spec, &calendars, None).await?;
        Ok(self.store.schedule_create(params).await?)
    }

    /// Contrôle puis modifie une planification (`fn::scheduler_schedule_update`) : les règles
    /// et les calendriers résultants (nouveaux ou conservés) sont contrôlés quand l'un des deux
    /// change ; l'ancre des intervalles reste la création de la planification (U3).
    pub async fn schedule_update(&self, params: ScheduleUpdateParams) -> SchedulerResult<Schedule> {
        let clears_calendars = params
            .clear
            .as_ref()
            .is_some_and(|c| c.iter().any(|f| f == "calendars"));
        if params.spec.is_some() || params.calendars.is_some() || clears_calendars {
            let current = self
                .store
                .schedule_get(ScheduleRefParams {
                    schedule: params.schedule.clone(),
                    language: params.language.clone(),
                })
                .await?;
            let spec = params.spec.as_ref().unwrap_or(&current.spec);
            let calendars = if clears_calendars {
                Vec::new()
            } else {
                params.calendars.clone().unwrap_or(current.calendars)
            };
            self.validate_spec(spec, &calendars, Some(&current.created_at))
                .await?;
        }
        Ok(self.store.schedule_update(params).await?)
    }

    /// Les `count` prochaines échéances (100 au plus) d'une planification, après maintenant,
    /// avec leur heure locale.
    pub async fn forecast(
        &self,
        schedule: SchedulerRecordId,
        count: usize,
    ) -> SchedulerResult<Vec<ForecastEntry>> {
        let current = self
            .store
            .schedule_get(ScheduleRefParams {
                schedule,
                language: None,
            })
            .await?;
        let calendars = self.calendar_set(&current.calendars).await?;
        let created_at = to_timestamp("created_at", &current.created_at)?;
        let spec = Spec::parse(&current.spec, created_at, calendars)?;
        let entries = spec
            .forecast(Timestamp::now(), count)?
            .into_iter()
            .map(|zoned| {
                Ok(ForecastEntry {
                    fire_at: to_datetime(zoned.timestamp())?,
                    local: zoned.to_string(),
                })
            })
            .collect::<Result<Vec<_>, SpecError>>()?;
        Ok(entries)
    }
}
