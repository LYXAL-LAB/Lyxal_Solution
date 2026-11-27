// SPDX-License-Identifier: AGPL-3.0-only

//! Connexions gardées et limites du nœud (plan du lot 6, §5.4, §6.5 ; décisions E7, E11).
//!
//! * [`ConnectionPool`] : une connexion qui a fini une transaction reste ouverte
//!   `idle_timeout` (60 s, valeur de KumoMTA) pour le prochain envoi vers le même serveur, la
//!   même adresse et le même mode TLS ; fermée après `messages_per_connection` messages, à
//!   l'arrêt du nœud (`QUIT`) ou sur toute erreur.
//! * [`DestinationLimiter`] : connexions simultanées du nœud et par destination (sémaphores),
//!   messages par minute d'une destination réglée. Limites **par nœud**, en mémoire, comme les
//!   cadences du lot 3 : sur plusieurs nœuds, elles s'additionnent.

use std::collections::HashMap;
use std::net::IpAddr;
use std::sync::{Arc, Mutex, PoisonError};
use std::time::{Duration, Instant};
use tokio::sync::{OwnedSemaphorePermit, Semaphore};

use crate::outbound::client::{SmtpConnection, TargetTls};
use crate::outbound::config::OutboundConfig;

/// Clé d'une connexion gardée.
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub struct PoolKey {
    /// Serveur.
    pub host: String,
    /// Adresse.
    pub ip: IpAddr,
    /// Mode TLS demandé.
    pub tls: TargetTls,
}

/// Connexions inactives du nœud.
pub struct ConnectionPool {
    idle: Mutex<HashMap<PoolKey, Vec<SmtpConnection>>>,
    idle_timeout: Duration,
    max_messages: u32,
    max_per_key: usize,
}

impl ConnectionPool {
    /// Pool des réglages du nœud.
    pub fn new(config: &OutboundConfig) -> Self {
        Self {
            idle: Mutex::new(HashMap::new()),
            idle_timeout: config.idle_timeout,
            max_messages: config.messages_per_connection,
            max_per_key: usize::try_from(config.connections_per_destination).unwrap_or(4),
        }
    }

    /// Connexion inactive encore fraîche pour `key`, s'il y en a une.
    pub fn take(&self, key: &PoolKey) -> Option<SmtpConnection> {
        let mut idle = self.idle.lock().unwrap_or_else(PoisonError::into_inner);
        let list = idle.get_mut(key)?;
        while let Some(connection) = list.pop() {
            if connection.idle_since.elapsed() < self.idle_timeout {
                return Some(connection);
            }
        }
        None
    }

    /// Garde une connexion utilisable ; rendue à l'appelant (à fermer) si elle a servi son
    /// nombre de messages ou si la place manque.
    pub fn put(&self, key: PoolKey, connection: SmtpConnection) -> Option<SmtpConnection> {
        if connection.messages >= self.max_messages {
            return Some(connection);
        }
        let mut idle = self.idle.lock().unwrap_or_else(PoisonError::into_inner);
        let list = idle.entry(key).or_default();
        if list.len() >= self.max_per_key {
            return Some(connection);
        }
        list.push(connection);
        None
    }

    /// Connexions inactives depuis plus que le délai, retirées (à fermer).
    pub fn expired(&self) -> Vec<SmtpConnection> {
        let mut idle = self.idle.lock().unwrap_or_else(PoisonError::into_inner);
        let mut expired = Vec::new();
        for list in idle.values_mut() {
            let (fresh, old): (Vec<_>, Vec<_>) = std::mem::take(list)
                .into_iter()
                .partition(|connection| connection.idle_since.elapsed() < self.idle_timeout);
            *list = fresh;
            expired.extend(old);
        }
        idle.retain(|_, list| !list.is_empty());
        expired
    }

    /// Toutes les connexions inactives, retirées (arrêt du nœud).
    pub fn drain(&self) -> Vec<SmtpConnection> {
        let mut idle = self.idle.lock().unwrap_or_else(PoisonError::into_inner);
        idle.drain().flat_map(|(_, list)| list).collect()
    }

    /// Connexions inactives gardées.
    pub fn len(&self) -> usize {
        let idle = self.idle.lock().unwrap_or_else(PoisonError::into_inner);
        idle.values().map(Vec::len).sum()
    }

    /// Vrai si aucune connexion n'est gardée.
    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }
}

/// Places prises par un envoi : connexion du nœud et connexion de la destination.
pub struct Slot {
    _total: OwnedSemaphorePermit,
    _destination: OwnedSemaphorePermit,
}

/// Limites du nœud : connexions totales, par destination, messages par minute.
pub struct DestinationLimiter {
    total: Arc<Semaphore>,
    max_total: usize,
    default_per_destination: usize,
    overrides: HashMap<String, (Option<u32>, Option<u32>)>,
    destinations: Mutex<HashMap<String, (Arc<Semaphore>, usize)>>,
    windows: Mutex<HashMap<String, (Instant, u32)>>,
}

impl DestinationLimiter {
    /// Limites des réglages du nœud.
    pub fn new(config: &OutboundConfig) -> Self {
        let max_total = usize::try_from(config.max_connections).unwrap_or(100);
        Self {
            total: Arc::new(Semaphore::new(max_total)),
            max_total,
            default_per_destination: usize::try_from(config.connections_per_destination)
                .unwrap_or(4),
            overrides: config
                .destinations
                .iter()
                .map(|d| (d.domain.clone(), (d.connections, d.messages_per_minute)))
                .collect(),
            destinations: Mutex::new(HashMap::new()),
            windows: Mutex::new(HashMap::new()),
        }
    }

    fn semaphore(&self, destination: &str) -> (Arc<Semaphore>, usize) {
        let mut map = self
            .destinations
            .lock()
            .unwrap_or_else(PoisonError::into_inner);
        map.entry(destination.to_string())
            .or_insert_with(|| {
                let size = self
                    .overrides
                    .get(destination)
                    .and_then(|(connections, _)| *connections)
                    .and_then(|value| usize::try_from(value).ok())
                    .unwrap_or(self.default_per_destination);
                (Arc::new(Semaphore::new(size)), size)
            })
            .clone()
    }

    /// Prend une place du nœud et de la destination (attend qu'elles se libèrent).
    pub async fn acquire(&self, destination: &str) -> Option<Slot> {
        let (semaphore, _) = self.semaphore(destination);
        let destination = semaphore.acquire_owned().await.ok()?;
        let total = self.total.clone().acquire_owned().await.ok()?;
        Some(Slot {
            _total: total,
            _destination: destination,
        })
    }

    /// Places libres du nœud.
    pub fn free(&self) -> usize {
        self.total.available_permits()
    }

    /// Connexions en cours du nœud.
    pub fn in_use(&self) -> usize {
        self.max_total
            .saturating_sub(self.total.available_permits())
    }

    /// Destinations dont toutes les places sont prises (écartées de la prochaine réservation),
    /// 1 000 au plus.
    pub fn saturated(&self) -> Vec<String> {
        let map = self
            .destinations
            .lock()
            .unwrap_or_else(PoisonError::into_inner);
        map.iter()
            .filter(|(_, (semaphore, _))| semaphore.available_permits() == 0)
            .map(|(domain, _)| domain.clone())
            .take(1_000)
            .collect()
    }

    /// Un message de plus vers `destination` cette minute : `Ok`, ou le délai jusqu'à la
    /// prochaine place (destination réglée en messages par minute).
    pub fn take_message(&self, destination: &str) -> Result<(), Duration> {
        let Some(limit) = self
            .overrides
            .get(destination)
            .and_then(|(_, per_minute)| *per_minute)
        else {
            return Ok(());
        };
        let mut windows = self.windows.lock().unwrap_or_else(PoisonError::into_inner);
        let now = Instant::now();
        let window = windows.entry(destination.to_string()).or_insert((now, 0));
        if now.duration_since(window.0) >= Duration::from_secs(60) {
            *window = (now, 0);
        }
        if window.1 >= limit {
            return Err(Duration::from_secs(60).saturating_sub(now.duration_since(window.0)));
        }
        window.1 += 1;
        Ok(())
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used)]
mod tests {
    use super::*;
    use crate::outbound::config::DestinationOverride;

    #[tokio::test]
    async fn destination_and_node_limits_are_held() {
        let mut config = OutboundConfig::new("mx.lyxal.test", "n1");
        config.max_connections = 3;
        config.connections_per_destination = 2;
        config.destinations = vec![DestinationOverride {
            domain: "lent.test".into(),
            connections: Some(1),
            messages_per_minute: Some(2),
        }];
        let limiter = DestinationLimiter::new(&config);
        let a = limiter.acquire("a.test").await.unwrap();
        let _b = limiter.acquire("a.test").await.unwrap();
        assert_eq!(limiter.saturated(), vec!["a.test".to_string()]);
        let _c = limiter.acquire("lent.test").await.unwrap();
        assert_eq!(limiter.free(), 0);
        assert_eq!(limiter.in_use(), 3);
        drop(a);
        assert_eq!(limiter.free(), 1);
        assert!(limiter.take_message("lent.test").is_ok());
        assert!(limiter.take_message("lent.test").is_ok());
        assert!(limiter.take_message("lent.test").is_err());
        assert!(
            limiter.take_message("a.test").is_ok(),
            "aucune cadence sans réglage"
        );
    }
}
