/*
 * SPDX-FileCopyrightText: 2020 Stalwart Labs LLC <hello@stalw.art>
 *
 * SPDX-License-Identifier: AGPL-3.0-only
 *
 * Porté de Stalwart, `crates/common/src/network/limiter.rs` (commit 3adead9, licence
 * `AGPL-3.0-only OR LicenseRef-SEL`, option AGPL-3.0-only retenue). Modifié pour Lyxal OS :
 * seul le plafond de connexions simultanées (`ConcurrencyLimiter`, `InFlight`) est repris ;
 * prise de place atomique (comparaison-échange) au lieu de « lire puis ajouter », qui pouvait
 * dépasser le plafond sous concurrence ; compteur `u32`.
 */

//! Plafond de connexions simultanées d'une écoute.

use std::sync::atomic::{AtomicU32, Ordering};
use std::sync::Arc;

/// Plafond de connexions simultanées d'une écoute. Clonable : les clones partagent le compteur.
#[derive(Clone, Debug)]
pub struct ConnectionLimiter(Arc<LimiterInner>);

#[derive(Debug)]
struct LimiterInner {
    max: u32,
    current: AtomicU32,
}

/// Place prise dans un [`ConnectionLimiter`], rendue à sa libération (fin de la connexion,
/// quelle qu'en soit l'issue, y compris l'annulation de sa tâche).
#[derive(Debug)]
pub struct InFlight(Arc<LimiterInner>);

impl Drop for InFlight {
    fn drop(&mut self) {
        self.0.current.fetch_sub(1, Ordering::AcqRel);
    }
}

impl ConnectionLimiter {
    /// Plafond de `max` connexions simultanées.
    pub fn new(max: u32) -> Self {
        Self(Arc::new(LimiterInner {
            max,
            current: AtomicU32::new(0),
        }))
    }

    /// Prend une place, ou `None` si le plafond est atteint.
    pub fn try_acquire(&self) -> Option<InFlight> {
        self.0
            .current
            .fetch_update(Ordering::AcqRel, Ordering::Acquire, |current| {
                (current < self.0.max).then_some(current + 1)
            })
            .ok()
            .map(|_| InFlight(self.0.clone()))
    }

    /// Places prises.
    pub fn in_use(&self) -> u32 {
        self.0.current.load(Ordering::Acquire)
    }

    /// Plafond.
    pub fn max(&self) -> u32 {
        self.0.max
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used, clippy::panic)]
mod tests {
    use super::*;

    #[test]
    fn places_are_capped_and_returned_on_drop() {
        let limiter = ConnectionLimiter::new(2);
        let first = limiter.try_acquire().expect("première place");
        let second = limiter.try_acquire().expect("deuxième place");
        assert!(limiter.try_acquire().is_none());
        assert_eq!(limiter.in_use(), 2);
        drop(first);
        assert_eq!(limiter.in_use(), 1);
        let third = limiter.try_acquire().expect("place rendue");
        drop((second, third));
        assert_eq!(limiter.in_use(), 0);
    }

    #[tokio::test]
    async fn place_is_returned_when_its_task_is_aborted() {
        let limiter = ConnectionLimiter::new(1);
        let place = limiter.try_acquire().expect("place");
        let task = tokio::spawn(async move {
            let _place = place;
            std::future::pending::<()>().await;
        });
        tokio::task::yield_now().await;
        assert_eq!(limiter.in_use(), 1);
        task.abort();
        assert!(task.await.unwrap_err().is_cancelled());
        assert_eq!(limiter.in_use(), 0);
    }

    #[test]
    fn concurrent_acquisitions_never_exceed_the_cap() {
        let limiter = ConnectionLimiter::new(8);
        let held = std::sync::Mutex::new(Vec::new());
        std::thread::scope(|scope| {
            for _ in 0..16 {
                scope.spawn(|| {
                    for _ in 0..100 {
                        if let Some(place) = limiter.try_acquire() {
                            assert!(limiter.in_use() <= 8);
                            held.lock().unwrap().push(place);
                        }
                    }
                });
            }
        });
        assert_eq!(held.lock().unwrap().len(), 8);
    }
}
