//! Types partagés par plusieurs fonctions : règles de dates d'une planification, règle de
//! calendrier, politique de tentatives, erreur d'exécution, page de liste, suppression.

use lyxal_surreal::SurrealValue;

use super::enums::{RetryStrategy, RuleKind, RuleMode};
use super::types::{SchedulerDatetime, SchedulerDuration, SchedulerRecordId, SchedulerValue};

/// Règles de dates d'une planification (`spec` de `scheduler_schedule`), contrôlées par
/// `fn::scheduler_spec_check` (forme) et par le calcul des dates (`crate::spec`).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct ScheduleSpec {
    /// Expressions cron de 5 à 7 champs (secondes et année facultatives), 10 au plus.
    #[surreal(default)]
    pub cron: Vec<String>,
    /// Intervalles en durée réelle (U3), 10 au plus.
    #[surreal(default)]
    pub every: Vec<SchedulerDuration>,
    /// Date unique.
    pub at: Option<SchedulerDatetime>,
    /// Expressions cron des dates exclues.
    #[surreal(default)]
    pub exclude_cron: Vec<String>,
    /// Fuseau horaire IANA des expressions cron et des calendriers.
    pub timezone: String,
    /// Début (inclus) ; ancre des intervalles.
    pub start_at: Option<SchedulerDatetime>,
    /// Fin (incluse).
    pub end_at: Option<SchedulerDatetime>,
    /// Décalage aléatoire maximal de chaque échéance (U5).
    pub jitter: Option<SchedulerDuration>,
}

impl ScheduleSpec {
    /// Règles vides dans le fuseau `timezone` : à compléter par au moins une expression cron,
    /// un intervalle ou une date unique.
    pub fn new(timezone: impl Into<String>) -> Self {
        Self {
            cron: Vec::new(),
            every: Vec::new(),
            at: None,
            exclude_cron: Vec::new(),
            timezone: timezone.into(),
            start_at: None,
            end_at: None,
            jitter: None,
        }
    }
}

/// Règle d'un calendrier d'exceptions.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct CalendarRule {
    /// Inclusion ou exclusion.
    pub mode: RuleMode,
    /// Sorte de règle.
    pub kind: RuleKind,
    /// Valeurs (1 à 400) : textes `AAAA-MM-JJ`, `MM-JJ`, `HH:MM-HH:MM`, ou entiers (jours).
    pub values: Vec<SchedulerValue>,
}

/// Règles d'un calendrier, telles que le moteur les reçoit (`fn::scheduler_due_list`).
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct CalendarRules {
    /// Calendrier.
    pub id: SchedulerRecordId,
    /// Règles.
    pub rules: Vec<CalendarRule>,
}

/// Politique de tentatives d'une tâche.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RetryPolicy {
    /// Tentatives permises (1 à 10).
    pub max_attempts: i64,
    /// Stratégie des délais.
    pub strategy: RetryStrategy,
    /// Délai initial.
    pub initial_delay: SchedulerDuration,
    /// Délai maximal.
    pub max_delay: SchedulerDuration,
}

/// Dernière erreur d'une exécution.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct RunError {
    /// Code de l'erreur.
    pub code: String,
    /// Message (1000 caractères au plus).
    pub message: Option<String>,
    /// Vrai si une nouvelle tentative pouvait réussir.
    pub retryable: bool,
}

/// Page d'une liste : éléments de la page et nombre total.
#[derive(Debug, Clone, SurrealValue)]
pub struct Page<T: SurrealValue> {
    /// Éléments de la page.
    pub items: Vec<T>,
    /// Nombre total d'éléments.
    pub total: i64,
}

/// Résultat d'une suppression.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
pub struct Deleted {
    /// Identifiant supprimé (`table:clé`).
    pub deleted: String,
}
