//! Sonde du moteur d'événements (`lyxal_event`) : signale les hôtes dont les livraisons attendent
//! sans chef vivant (hôte arrêté), à partir de `fn::event_backlog`.

use crate::context::ModuleContext;
use crate::error::RuntimeError;
use crate::health::check::{HealthCheckResult, ModuleHealthCheck};
use crate::types::ModuleId;
use async_trait::async_trait;
use lyxal_event::engine::dto::EventBacklog;
use lyxal_event::EventStore;
use std::sync::Arc;
use std::time::{Duration, Instant};

/// Identifiant de module de la sonde : le moteur d'événements.
pub const EVENT_MODULE_ID: &str = "lyxal_event";

/// Sonde de `lyxal_event`, enregistrée par le runtime avec le moteur d'événements.
///
/// « Dégradé » quand un hôte a des livraisons non soldées créées depuis plus de `alert_after`
/// et aucun chef des événements vivant (son bail a expiré ou a été libéré) : l'hôte est arrêté,
/// ses livraisons attendent son retour (décision H4) ; le message nomme chaque hôte et le nombre
/// de livraisons en attente. Un hôte dont le chef est vivant n'est jamais signalé.
pub struct EventEngineHealthCheck {
    module_id: ModuleId,
    store: Arc<EventStore>,
    alert_after: Duration,
}

impl EventEngineHealthCheck {
    /// Crée la sonde, lue dans la base de `store`, avec le seuil `alert_after`.
    pub fn new(store: Arc<EventStore>, alert_after: Duration) -> Self {
        Self {
            module_id: ModuleId::new(EVENT_MODULE_ID),
            store,
            alert_after,
        }
    }

    /// Message de la sonde pour l'attente lue, ou `None` si aucun hôte n'est signalé.
    #[must_use]
    pub fn stalled_message(backlog: &[EventBacklog]) -> Option<String> {
        let stalled: Vec<String> = backlog
            .iter()
            .filter(|host| host.waiting > 0 && !host.leader_alive)
            .map(|host| {
                format!(
                    "hôte {} : {} livraison(s) en attente sans chef des événements vivant",
                    host.host, host.waiting
                )
            })
            .collect();
        (!stalled.is_empty()).then(|| stalled.join(" ; "))
    }
}

#[async_trait]
impl ModuleHealthCheck for EventEngineHealthCheck {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        let start = Instant::now();
        let backlog = self.store.backlog(self.alert_after).await.map_err(|e| {
            RuntimeError::EventEngineError {
                message: format!("lecture de l'attente des événements par hôte : {e}"),
            }
        })?;
        let latency_ms = u64::try_from(start.elapsed().as_millis()).unwrap_or(u64::MAX);
        Ok(match Self::stalled_message(&backlog) {
            Some(message) => {
                HealthCheckResult::degraded(self.module_id.clone(), latency_ms, Some(message))
            }
            None => HealthCheckResult::healthy(
                self.module_id.clone(),
                latency_ms,
                Some("Chaque hôte en attente a un chef des événements vivant".to_string()),
            ),
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn host(name: &str, waiting: u64, leader_alive: bool) -> EventBacklog {
        EventBacklog {
            host: name.to_string(),
            pending: waiting + 1,
            waiting,
            oldest: None,
            leader_alive,
            leader_node: None,
        }
    }

    #[test]
    fn only_hosts_with_old_deliveries_and_no_leader_are_reported() {
        assert_eq!(EventEngineHealthCheck::stalled_message(&[]), None);
        assert_eq!(
            EventEngineHealthCheck::stalled_message(&[
                host("lyxal_server", 4, true),
                host("lyxal_groupware", 0, false)
            ]),
            None
        );
        let message = EventEngineHealthCheck::stalled_message(&[
            host("lyxal_groupware", 3, false),
            host("lyxal_server", 2, true),
        ])
        .expect("hôte signalé");
        assert!(message.contains("lyxal_groupware : 3"), "{message}");
        assert!(!message.contains("lyxal_server"), "{message}");
    }
}
