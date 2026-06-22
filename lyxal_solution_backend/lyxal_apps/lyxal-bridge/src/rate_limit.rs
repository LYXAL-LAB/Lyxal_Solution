//! Rate limiter par provider avec fenêtre glissante (sliding window).
//!
//! Chaque provider peut avoir une limite de requêtes par fenêtre de temps.
//! Ce module empêche de dépasser cette limite pour éviter le bannissement
//! par les APIs tierces.
//!
//! Repris et adapté de `lyxal_core_connector/src/rate_limit.rs`.

use std::collections::VecDeque;
use std::sync::{LazyLock, Mutex};
use std::time::Instant;

use crate::error::BridgeError;

/// État global des rate limiters, indexé par nom de provider.
///
/// Chaque entrée contient un `VecDeque<Instant>` des timestamps
/// des requêtes récentes dans la fenêtre glissante.
static RATE_LIMITERS: LazyLock<Mutex<std::collections::HashMap<String, VecDeque<Instant>>>> =
    LazyLock::new(|| Mutex::new(std::collections::HashMap::new()));

/// Vérifie le rate limit pour un provider et enregistre la requête.
///
/// Retourne `Ok(())` si la requête est autorisée, ou
/// `Err(BridgeError::RateLimitExceeded)` si la limite est dépassée.
///
/// # Arguments
/// * `provider_name` — Nom du provider (clé du limiter)
/// * `max_requests` — Nombre max de requêtes autorisées dans la fenêtre
/// * `window_ms` — Taille de la fenêtre en millisecondes
pub fn check_rate_limit(
    provider_name: &str,
    max_requests: u32,
    window_ms: u64,
) -> Result<(), BridgeError> {
    let now = Instant::now();
    let window = std::time::Duration::from_millis(window_ms);

    let mut limiters = RATE_LIMITERS
        .lock()
        .unwrap_or_else(|e| e.into_inner());

    let timestamps = limiters
        .entry(provider_name.to_string())
        .or_insert_with(VecDeque::new);

    // Purger les timestamps hors de la fenêtre courante
    while let Some(&front) = timestamps.front() {
        if now.duration_since(front) > window {
            timestamps.pop_front();
        } else {
            break;
        }
    }

    // Vérifier si on est à la limite
    if timestamps.len() >= max_requests as usize {
        return Err(BridgeError::RateLimitExceeded {
            provider: provider_name.to_string(),
            limit: max_requests,
            per_ms: window_ms,
        });
    }

    // Enregistrer cette requête
    timestamps.push_back(now);

    Ok(())
}

/// Réinitialise le rate limiter pour un provider.
pub fn reset_rate_limit(provider_name: &str) {
    let mut limiters = RATE_LIMITERS
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    limiters.remove(provider_name);
}

/// Réinitialise tous les rate limiters.
pub fn reset_all_rate_limits() {
    let mut limiters = RATE_LIMITERS
        .lock()
        .unwrap_or_else(|e| e.into_inner());
    limiters.clear();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_rate_limit_allows_within_limit() {
        reset_rate_limit("test_provider_1");
        assert!(check_rate_limit("test_provider_1", 5, 60000).is_ok());
        assert!(check_rate_limit("test_provider_1", 5, 60000).is_ok());
        assert!(check_rate_limit("test_provider_1", 5, 60000).is_ok());
    }

    #[test]
    fn test_rate_limit_blocks_over_limit() {
        reset_rate_limit("test_provider_2");
        for _ in 0..3 {
            check_rate_limit("test_provider_2", 3, 60000).unwrap();
        }
        // La 4ème doit échouer
        assert!(check_rate_limit("test_provider_2", 3, 60000).is_err());
    }
}
