use super::config::EventWorkerConfig;
use std::time::Duration;

/// Calcule le délai de retry selon un backoff exponentiel borné avec Full Jitter.
///
/// Formule : `min(retry_max_delay, retry_base_delay * 2^attempts)`
/// Si `jitter` est actif : tirage aléatoire uniforme dans `[0, computed_delay]`.
#[must_use]
pub fn compute_next_retry_delay(config: &EventWorkerConfig, attempts: u32) -> Duration {
    let factor = 1u32.checked_shl(attempts).unwrap_or(u32::MAX);
    let capped = config
        .retry_base_delay
        .saturating_mul(factor)
        .min(config.retry_max_delay);

    if config.jitter {
        let nanos = capped.as_nanos();
        let nanos_u64 = u64::try_from(nanos).unwrap_or(u64::MAX);
        if nanos_u64 == 0 {
            Duration::ZERO
        } else {
            Duration::from_nanos(fastrand::u64(0..=nanos_u64))
        }
    } else {
        capped
    }
}

/// Dimensionne la durée totale du bail couvrant le traitement séquentiel d'un lot entier.
///
/// Formule : `batch_len * dispatch_timeout` (avec floor à 1 élément).
#[must_use]
pub fn compute_lease_duration(config: &EventWorkerConfig, batch_len: usize) -> Duration {
    let count = u32::try_from(batch_len.max(1)).unwrap_or(u32::MAX);
    config.dispatch_timeout.saturating_mul(count)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_retry_delay_without_jitter_increases_exponentially() {
        let mut cfg = EventWorkerConfig::default();
        cfg.jitter = false;
        cfg.retry_base_delay = Duration::from_secs(1);
        cfg.retry_max_delay = Duration::from_secs(60);

        assert_eq!(compute_next_retry_delay(&cfg, 0), Duration::from_secs(1));
        assert_eq!(compute_next_retry_delay(&cfg, 1), Duration::from_secs(2));
        assert_eq!(compute_next_retry_delay(&cfg, 2), Duration::from_secs(4));
        assert_eq!(compute_next_retry_delay(&cfg, 3), Duration::from_secs(8));
        assert_eq!(compute_next_retry_delay(&cfg, 10), Duration::from_secs(60));
    }

    #[test]
    fn test_retry_delay_with_jitter_stays_bounded() {
        let cfg = EventWorkerConfig::default();
        for attempt in 0..10 {
            let delay = compute_next_retry_delay(&cfg, attempt);
            assert!(delay <= cfg.retry_max_delay);
        }
    }

    #[test]
    fn test_lease_duration_scales_with_batch_length() {
        let cfg = EventWorkerConfig::default();
        assert_eq!(compute_lease_duration(&cfg, 1), cfg.dispatch_timeout);
        assert_eq!(compute_lease_duration(&cfg, 5), cfg.dispatch_timeout * 5);
    }
}
