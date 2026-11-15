//! Code Rust des tâches `handler` : chaque module qui déclare une tâche `handler` inscrit son
//! [`TaskHandler`] dans le [`HandlerRegistry`] de l'hôte au démarrage. Le moteur appelle le
//! handler d'une exécution réservée, sous la session système (T2), avec un [`RunContext`] qui ne
//! contient aucun secret (pas de jeton de bail) ; il doit être idempotent (S7) : la clé de
//! l'exécution (`RunContext::run`) sert de clé d'idempotence.

use async_trait::async_trait;
use lyxal_runtime::worker::CancellationToken;
use std::collections::BTreeMap;
use std::fmt;
use std::sync::{Arc, PoisonError, RwLock};

use crate::error::{SchedulerError, SchedulerResult};
use crate::models::{SchedulerDatetime, SchedulerRecordId, SchedulerValue};

/// Code d'une tâche `handler`, inscrit par son module.
#[async_trait]
pub trait TaskHandler: Send + Sync {
    /// Nom de la tâche déclarée (`notification.digest`).
    fn task(&self) -> &str;

    /// Exécute une tentative ; doit être idempotent (S7) et s'arrêter dès que
    /// `ctx.cancellation` est annulé (annulation demandée, délai maximal, arrêt du nœud).
    async fn run(&self, ctx: RunContext) -> Result<TaskOutput, TaskFailure>;
}

/// Contexte d'une tentative remis au handler (rien de secret).
#[derive(Debug, Clone)]
pub struct RunContext {
    /// Exécution (clé d'idempotence).
    pub run: SchedulerRecordId,
    /// Organisation (absente : installation) ; le handler ne touche que cette organisation.
    pub tenant: Option<SchedulerRecordId>,
    /// Planification d'origine (absente : exécution différée ou immédiate).
    pub schedule: Option<SchedulerRecordId>,
    /// Date prévue.
    pub scheduled_for: SchedulerDatetime,
    /// Tentative en cours (à partir de 1).
    pub attempt: i64,
    /// Tentatives permises.
    pub max_attempts: i64,
    /// Arguments, contrôlés par le schéma déclaré avec la tâche.
    pub args: SchedulerValue,
    /// Annulé quand l'annulation est demandée, le délai maximal dépassé ou le nœud arrêté.
    pub cancellation: CancellationToken,
}

/// Résultat d'une tentative réussie.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct TaskOutput {
    /// Résultat court (objet de 4 Kio au plus, gardé sur l'exécution) ; jamais de secret.
    pub result: Option<SchedulerValue>,
}

impl TaskOutput {
    /// Succès sans résultat.
    pub fn empty() -> Self {
        Self::default()
    }

    /// Succès avec un résultat court.
    pub fn with_result(result: SchedulerValue) -> Self {
        Self {
            result: Some(result),
        }
    }
}

/// Échec d'une tentative : un code stable, un message sans secret et la possibilité d'une
/// nouvelle tentative (selon la politique de la tâche).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TaskFailure {
    /// Code de l'erreur (128 caractères au plus).
    pub code: String,
    /// Message (tronqué à 1000 caractères à l'enregistrement).
    pub message: String,
    /// Vrai si une nouvelle tentative peut réussir.
    pub retryable: bool,
}

impl TaskFailure {
    /// Échec passager : une nouvelle tentative est prévue s'il en reste.
    pub fn retryable(code: impl Into<String>, message: impl Into<String>) -> Self {
        Self {
            code: code.into(),
            message: message.into(),
            retryable: true,
        }
    }

    /// Échec définitif : l'exécution finit `dead`.
    pub fn terminal(code: impl Into<String>, message: impl Into<String>) -> Self {
        Self {
            code: code.into(),
            message: message.into(),
            retryable: false,
        }
    }
}

impl fmt::Display for TaskFailure {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{} : {}", self.code, self.message)
    }
}

/// Nom de tâche `<module>.<action>` en minuscules (chiffres et `_` permis).
fn valid_task_name(name: &str) -> bool {
    let mut parts = name.split('.');
    let segment = |s: Option<&str>| {
        s.is_some_and(|s| {
            s.starts_with(|c: char| c.is_ascii_lowercase())
                && s.bytes()
                    .all(|b| b.is_ascii_lowercase() || b.is_ascii_digit() || b == b'_')
        })
    };
    segment(parts.next()) && segment(parts.next()) && parts.next().is_none()
}

/// Registre des handlers, rempli par les modules au démarrage de l'hôte. Les copies partagent
/// le même registre : l'hôte le remplit, les exécuteurs et la sonde le lisent.
#[derive(Clone, Default)]
pub struct HandlerRegistry {
    handlers: Arc<RwLock<BTreeMap<String, Arc<dyn TaskHandler>>>>,
}

impl fmt::Debug for HandlerRegistry {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("HandlerRegistry")
            .field("tasks", &self.tasks())
            .finish()
    }
}

impl HandlerRegistry {
    /// Registre vide.
    pub fn new() -> Self {
        Self::default()
    }

    /// Inscrit le handler de sa tâche ; un nom mal formé ou un deuxième handler pour la même
    /// tâche est refusé (`SCHEDULER_INVALID_PARAMETERS`).
    pub fn register(&mut self, handler: Arc<dyn TaskHandler>) -> SchedulerResult<()> {
        let task = handler.task().to_string();
        if !valid_task_name(&task) {
            return Err(SchedulerError::Handler {
                task,
                reason: "nom de tâche <module>.<action> attendu",
            });
        }
        // Un verrou empoisonné (panique d'un autre fil) garde un registre cohérent : chaque
        // écriture est une insertion complète
        let mut handlers = self
            .handlers
            .write()
            .unwrap_or_else(PoisonError::into_inner);
        if handlers.contains_key(&task) {
            return Err(SchedulerError::Handler {
                task,
                reason: "un handler est déjà inscrit pour cette tâche",
            });
        }
        handlers.insert(task, handler);
        Ok(())
    }

    /// Handler inscrit pour la tâche `task`.
    pub fn get(&self, task: &str) -> Option<Arc<dyn TaskHandler>> {
        self.handlers
            .read()
            .unwrap_or_else(PoisonError::into_inner)
            .get(task)
            .cloned()
    }

    /// Noms des tâches qui ont un handler inscrit, dans l'ordre.
    pub fn tasks(&self) -> Vec<String> {
        self.handlers
            .read()
            .unwrap_or_else(PoisonError::into_inner)
            .keys()
            .cloned()
            .collect()
    }

    /// Vrai si aucun handler n'est inscrit.
    pub fn is_empty(&self) -> bool {
        self.tasks().is_empty()
    }
}
