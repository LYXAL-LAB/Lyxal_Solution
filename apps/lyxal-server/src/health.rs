use chrono::{DateTime, Utc};
use serde::Serialize;
use std::{collections::BTreeMap, sync::Arc};
use tokio::sync::RwLock;

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum HealthState {
    Starting,
    Healthy,
    Degraded,
    Unhealthy,
    Stopping,
}

#[derive(Clone, Debug, Serialize)]
pub struct ComponentHealth {
    pub state: HealthState,
    pub message: Option<String>,
    pub checked_at: DateTime<Utc>,
}

#[derive(Clone, Default)]
pub struct HealthRegistry {
    components: Arc<RwLock<BTreeMap<String, ComponentHealth>>>,
}

#[derive(Debug, Serialize)]
pub struct HealthSnapshot {
    pub state: HealthState,
    pub components: BTreeMap<String, ComponentHealth>,
}

impl HealthRegistry {
    pub async fn set(
        &self,
        component: impl Into<String>,
        state: HealthState,
        message: Option<String>,
    ) {
        self.components.write().await.insert(
            component.into(),
            ComponentHealth {
                state,
                message,
                checked_at: Utc::now(),
            },
        );
    }

    pub async fn snapshot(&self) -> HealthSnapshot {
        let components = self.components.read().await.clone();
        let state = aggregate(components.values().map(|value| value.state));
        HealthSnapshot { state, components }
    }

    pub async fn ready(&self) -> bool {
        matches!(
            self.snapshot().await.state,
            HealthState::Healthy | HealthState::Degraded
        )
    }
}

fn aggregate(states: impl Iterator<Item = HealthState>) -> HealthState {
    let mut has_degraded = false;
    let mut has_starting = false;
    let mut has_stopping = false;

    for state in states {
        match state {
            HealthState::Unhealthy => return HealthState::Unhealthy,
            HealthState::Degraded => has_degraded = true,
            HealthState::Starting => has_starting = true,
            HealthState::Stopping => has_stopping = true,
            HealthState::Healthy => {}
        }
    }

    if has_stopping {
        HealthState::Stopping
    } else if has_starting {
        HealthState::Starting
    } else if has_degraded {
        HealthState::Degraded
    } else {
        HealthState::Healthy
    }
}
