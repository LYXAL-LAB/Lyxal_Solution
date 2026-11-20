// SPDX-FileCopyrightText: 2021 Mechiel Lukkien <mechiel@ueber.net>
//
// SPDX-License-Identifier: MIT
//
// Transposé en Rust de Mox, `ratelimit/ratelimit.go` (commit b32f0de, licence MIT ; avis de
// copyright et de licence dans `LICENSES/MIT-Mox.txt`), et ses cas d'essai de
// `ratelimit/ratelimit_test.go`. Modifié pour Lyxal OS : nombre de réseaux suivis borné par
// fenêtre (refus plutôt qu'allocation sans limite) ; aucun `panic!` ; adresse IPv4 transportée
// en IPv6 ramenée à l'IPv4 avant masquage ; `release` retire les entrées tombées à zéro ;
// instants monotones (`Instant`) au lieu de l'heure murale.

//! Limiteur par réseau : fenêtres fixes, trois niveaux de réseau par adresse.
//!
//! Chaque adresse est comptée trois fois : elle-même et deux réseaux voisins de plus en plus
//! larges (IPv4 `/32`, `/26`, `/21` ; IPv6 `/64`, `/48`, `/32`), car un client change facilement
//! d'adresse dans son réseau. Une fenêtre (une minute, par exemple) remet ses compteurs à zéro
//! à son terme ; une fenêtre de durée [`Duration::MAX`] ne se termine jamais et compte des
//! ressources ouvertes (connexions), rendues par [`IpRateLimiter::release`].

use std::collections::HashMap;
use std::net::IpAddr;
use std::sync::{Mutex, MutexGuard};
use std::time::{Duration, Instant};

/// Nombre de réseaux suivis par fenêtre et par défaut.
pub const DEFAULT_MAX_TRACKED_NETWORKS: usize = 100_000;

/// Limites d'une fenêtre, pour chaque niveau de réseau (adresse, petit réseau, grand réseau).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct WindowLimit {
    /// Durée de la fenêtre ; [`Duration::MAX`] : fenêtre sans fin (ressources ouvertes).
    pub window: Duration,
    /// Limites des trois niveaux de réseau.
    pub limits: [u64; 3],
}

/// Clé d'un compteur : niveau de réseau et adresse masquée (IPv4 en forme IPv6 transposée).
type Key = (u8, [u8; 16]);

#[derive(Debug)]
struct Window {
    limit: WindowLimit,
    index: u128,
    counts: HashMap<Key, u64>,
}

/// Limiteur par réseau, en mémoire, partagé par les écoutes d'un nœud.
#[derive(Debug)]
pub struct IpRateLimiter {
    origin: Instant,
    max_tracked: usize,
    windows: Mutex<Vec<Window>>,
}

impl IpRateLimiter {
    /// Limiteur à fenêtres `windows`, avec au plus [`DEFAULT_MAX_TRACKED_NETWORKS`] réseaux
    /// suivis par fenêtre.
    pub fn new(windows: Vec<WindowLimit>) -> Self {
        Self::with_max_tracked_networks(windows, DEFAULT_MAX_TRACKED_NETWORKS)
    }

    /// Limiteur à fenêtres `windows`, avec au plus `max_tracked` compteurs par fenêtre : au-delà,
    /// toute nouvelle adresse est refusée (surcharge) jusqu'à la fin de la fenêtre.
    pub fn with_max_tracked_networks(windows: Vec<WindowLimit>, max_tracked: usize) -> Self {
        Self {
            origin: Instant::now(),
            max_tracked,
            windows: Mutex::new(
                windows
                    .into_iter()
                    .map(|limit| Window {
                        limit,
                        index: 0,
                        counts: HashMap::new(),
                    })
                    .collect(),
            ),
        }
    }

    /// Compte `n` pour `ip` à l'instant `now` si aucune limite de niveau ni de fenêtre n'est
    /// dépassée : tout ou rien. Faux sinon, et rien n'est compté.
    pub fn try_add(&self, ip: IpAddr, now: Instant, n: u64) -> bool {
        self.check_add(true, ip, now, n)
    }

    /// Vrai si `n` pourrait être compté pour `ip` à l'instant `now` (rien n'est compté).
    pub fn can_add(&self, ip: IpAddr, now: Instant, n: u64) -> bool {
        self.check_add(false, ip, now, n)
    }

    /// Rend `n` à `ip` dans les fenêtres en cours (connexions ouvertes refermées).
    pub fn release(&self, ip: IpAddr, now: Instant, n: u64) {
        let keys = keys(ip);
        let mut windows = self.lock();
        for window in windows.iter_mut() {
            if window.index != self.index(window.limit.window, now) {
                continue;
            }
            for key in &keys {
                if let Some(count) = window.counts.get_mut(key) {
                    *count = count.saturating_sub(n);
                    if *count == 0 {
                        window.counts.remove(key);
                    }
                }
            }
        }
    }

    /// Réseaux suivis, toutes fenêtres (mesure).
    pub fn tracked(&self) -> usize {
        self.lock().iter().map(|window| window.counts.len()).sum()
    }

    fn check_add(&self, add: bool, ip: IpAddr, now: Instant, n: u64) -> bool {
        let keys = keys(ip);
        let mut windows = self.lock();
        for window in windows.iter_mut() {
            let index = self.index(window.limit.window, now);
            if index > window.index {
                window.index = index;
                window.counts.clear();
            }
            let mut missing = 0;
            for (level, key) in keys.iter().enumerate() {
                let count = window.counts.get(key).copied();
                if count.is_none() {
                    missing += 1;
                }
                if count.unwrap_or(0).saturating_add(n) > window.limit.limits[level] {
                    return false;
                }
            }
            if window.counts.len() + missing > self.max_tracked {
                return false;
            }
        }
        if add {
            for window in windows.iter_mut() {
                for key in &keys {
                    let count = window.counts.entry(*key).or_insert(0);
                    *count = count.saturating_add(n);
                }
            }
        }
        true
    }

    /// Numéro de la fenêtre de durée `window` qui contient `now`.
    fn index(&self, window: Duration, now: Instant) -> u128 {
        let elapsed = now.saturating_duration_since(self.origin).as_nanos();
        elapsed / window.as_nanos().max(1)
    }

    /// Verrou des fenêtres. Un verrou empoisonné (panique d'un autre fil pendant une mise à jour
    /// de compteurs) est repris : les compteurs restent cohérents à une opération près.
    fn lock(&self) -> MutexGuard<'_, Vec<Window>> {
        self.windows
            .lock()
            .unwrap_or_else(|poisoned| poisoned.into_inner())
    }
}

/// Clés des trois niveaux de réseau de `ip`.
fn keys(ip: IpAddr) -> [Key; 3] {
    let ip = match ip {
        IpAddr::V6(v6) => v6
            .to_ipv4_mapped()
            .map(IpAddr::V4)
            .unwrap_or(IpAddr::V6(v6)),
        v4 => v4,
    };
    match ip {
        IpAddr::V4(v4) => {
            let prefixes = [32u8, 26, 21];
            prefixes.map(|prefix| {
                let bits = u32::from(v4) & mask32(prefix);
                (
                    prefix,
                    std::net::Ipv4Addr::from(bits).to_ipv6_mapped().octets(),
                )
            })
        }
        IpAddr::V6(v6) => {
            let prefixes = [64u8, 48, 32];
            prefixes.map(|prefix| (prefix, (u128::from(v6) & mask128(prefix)).to_be_bytes()))
        }
    }
}

fn mask32(prefix: u8) -> u32 {
    u32::MAX.checked_shl(32 - u32::from(prefix)).unwrap_or(0)
}

fn mask128(prefix: u8) -> u128 {
    u128::MAX.checked_shl(128 - u32::from(prefix)).unwrap_or(0)
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used, clippy::panic)]
mod tests {
    use super::*;

    fn ip(text: &str) -> IpAddr {
        text.parse().unwrap()
    }

    fn check(limiter: &IpRateLimiter, expected: bool, address: &str, now: Instant, n: u64) {
        assert_eq!(
            limiter.can_add(ip(address), now, n),
            expected,
            "can_add {address}"
        );
        assert_eq!(
            limiter.try_add(ip(address), now, n),
            expected,
            "try_add {address}"
        );
    }

    /// Cas de `TestLimiter` de Mox, première partie : une fenêtre d'une minute.
    #[test]
    fn one_window_three_network_levels() {
        let limiter = IpRateLimiter::new(vec![WindowLimit {
            window: Duration::from_secs(60),
            limits: [2, 4, 6],
        }]);
        let now = Instant::now();
        check(&limiter, false, "10.0.0.1", now, 3); // au-delà de la limite
        check(&limiter, true, "10.0.0.1", now, 1);
        check(&limiter, false, "10.0.0.1", now, 2); // maintenant au-delà
        check(&limiter, true, "10.0.0.1", now, 1);
        check(&limiter, false, "10.0.0.1", now, 1); // maintenant au-delà

        let next = now + Duration::from_secs(60);
        check(&limiter, true, "10.0.0.1", next, 2); // minute suivante : remise à zéro
        check(&limiter, true, "10.0.0.2", next, 2); // autre adresse
        check(&limiter, false, "10.0.0.3", next, 2); // encore une autre : /26 épuisé
        check(&limiter, true, "10.0.1.4", next, 2); // autre /26 du même /21
        check(&limiter, false, "10.0.2.4", next, 2); // /21 épuisé
        limiter.release(ip("10.0.1.4"), next, 2);
        assert!(limiter.can_add(ip("10.0.1.4"), next, 2), "release");
        check(&limiter, true, "10.0.2.4", next, 2); // /21 de nouveau disponible
    }

    /// Cas de `TestLimiter` de Mox, seconde partie : deux fenêtres (minute et heure).
    #[test]
    fn two_windows() {
        let limiter = IpRateLimiter::new(vec![
            WindowLimit {
                window: Duration::from_secs(60),
                limits: [1, 2, 3],
            },
            WindowLimit {
                window: Duration::from_secs(3600),
                limits: [2, 3, 4],
            },
        ]);
        let min1 = Instant::now();
        let min2 = min1 + Duration::from_secs(60);
        let min3 = min1 + Duration::from_secs(120);
        check(&limiter, true, "10.0.0.1", min1, 1);
        check(&limiter, true, "10.0.0.1", min2, 1);
        check(&limiter, false, "10.0.0.1", min3, 1);
        check(&limiter, true, "10.0.0.255", min3, 1); // /26 encore libre
        check(&limiter, false, "10.0.0.255", min3, 1); // /26 plein
        check(&limiter, true, "10.0.1.1", min3, 1); // /21 encore libre
        check(&limiter, false, "10.0.1.255", min3, 1); // /21 plein
    }

    #[test]
    fn ipv6_levels_and_mapped_ipv4() {
        let limiter = IpRateLimiter::new(vec![WindowLimit {
            window: Duration::MAX,
            limits: [1, 2, 3],
        }]);
        let now = Instant::now();
        check(&limiter, true, "2001:db8:1:1::1", now, 1);
        check(&limiter, false, "2001:db8:1:1::2", now, 1); // même /64
        check(&limiter, true, "2001:db8:1:2::1", now, 1); // autre /64 du même /48
        check(&limiter, false, "2001:db8:1:3::1", now, 1); // /48 plein
        check(&limiter, true, "2001:db8:2::1", now, 1); // autre /48 du même /32
        check(&limiter, false, "2001:db8:3::1", now, 1); // /32 plein

        // IPv4 transportée en IPv6 : comptée comme l'IPv4
        check(&limiter, true, "192.0.2.1", now, 1);
        check(&limiter, false, "::ffff:192.0.2.1", now, 1);
    }

    #[test]
    fn open_connections_are_released_and_forgotten() {
        let limiter = IpRateLimiter::new(vec![WindowLimit {
            window: Duration::MAX,
            limits: [2, 90, 270],
        }]);
        let now = Instant::now();
        let later = now + Duration::from_secs(24 * 3600);
        check(&limiter, true, "198.51.100.7", now, 1);
        check(&limiter, true, "198.51.100.7", now, 1);
        check(&limiter, false, "198.51.100.7", later, 1);
        limiter.release(ip("198.51.100.7"), later, 1);
        check(&limiter, true, "198.51.100.7", later, 1);
        limiter.release(ip("198.51.100.7"), later, 2);
        // Les compteurs à zéro sont retirés : aucune mémoire gardée par adresse
        assert_eq!(limiter.tracked(), 0);
    }

    #[test]
    fn tracked_networks_are_bounded() {
        let limiter = IpRateLimiter::with_max_tracked_networks(
            vec![WindowLimit {
                window: Duration::from_secs(60),
                limits: [10, 10, 10],
            }],
            3,
        );
        let now = Instant::now();
        // Une adresse occupe trois compteurs (trois niveaux)
        check(&limiter, true, "10.0.0.1", now, 1);
        // Même réseaux : aucun compteur nouveau
        check(&limiter, true, "10.0.0.1", now, 1);
        // Adresse d'un autre réseau : refus (surcharge), rien n'est alloué
        check(&limiter, false, "172.16.0.1", now, 1);
        assert_eq!(limiter.tracked(), 3);
        // Fenêtre suivante : remise à zéro
        check(
            &limiter,
            true,
            "172.16.0.1",
            now + Duration::from_secs(60),
            1,
        );
    }
}
