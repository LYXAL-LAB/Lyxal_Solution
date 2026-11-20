/*
 * SPDX-FileCopyrightText: 2020 Stalwart Labs LLC <hello@stalw.art>
 *
 * SPDX-License-Identifier: AGPL-3.0-only
 *
 * Porté de Stalwart, `crates/common/src/network/memory.rs` (commit 3adead9, licence
 * `AGPL-3.0-only OR LicenseRef-SEL`, option AGPL-3.0-only retenue). Modifié pour Lyxal OS :
 * plafond global porté par le budget (et non par chaque réservation) ; plafond propre à chaque
 * réservation ; une réservation seule ne peut plus dépasser le budget (la somme réservée ne le
 * dépasse jamais) ; erreurs `NetError` au lieu du journal de Stalwart ; seuil « souple » de
 * Stalwart (`is_accepting`) non repris.
 */

//! Budget mémoire du processus, partagé par les connexions.
//!
//! Le budget est découpé en deux classes (réception SMTP, lecture) : chacune garde un plancher
//! d'un quart du budget, que l'autre ne peut pas lui prendre. Les réservations se font par pas
//! de 64 Kio ([`MEMORY_GRANULE`]) et sont rendues à leur libération.

use crate::net::session::NetError;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;

/// Pas des réservations (64 Kio).
pub const MEMORY_GRANULE: u64 = 64 * 1024;
const CLASS_FLOOR_SHARE: u64 = 4;

/// Classe d'usage de la mémoire.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum MemoryClass {
    /// Réception SMTP (corps des messages).
    SmtpInbound,
    /// Lecture (réponses IMAP, POP3, tampons des connexions).
    Read,
}

impl MemoryClass {
    fn index(self) -> usize {
        match self {
            Self::SmtpInbound => 0,
            Self::Read => 1,
        }
    }

    fn other(self) -> Self {
        match self {
            Self::SmtpInbound => Self::Read,
            Self::Read => Self::SmtpInbound,
        }
    }
}

/// Budget mémoire du processus. Clonable : les clones partagent les compteurs.
#[derive(Clone, Debug)]
pub struct MemoryBudget(Arc<BudgetInner>);

#[derive(Debug)]
struct BudgetInner {
    limit: u64,
    classes: [ClassCounter; 2],
}

#[derive(Debug, Default)]
#[repr(align(128))]
struct ClassCounter(AtomicU64);

impl MemoryBudget {
    /// Budget de `limit_bytes` octets.
    pub fn new(limit_bytes: u64) -> Self {
        Self(Arc::new(BudgetInner {
            limit: limit_bytes,
            classes: Default::default(),
        }))
    }

    /// Octets réservés, toutes classes.
    pub fn used(&self) -> u64 {
        self.used_by(MemoryClass::SmtpInbound)
            .saturating_add(self.used_by(MemoryClass::Read))
    }

    /// Octets réservés par la classe `class`.
    pub fn used_by(&self, class: MemoryClass) -> u64 {
        self.counter(class).load(Ordering::SeqCst)
    }

    /// Plafond du budget.
    pub fn limit(&self) -> u64 {
        self.0.limit
    }

    /// Réservation vide de la classe `class`, qui ne pourra pas dépasser `per_session_limit`
    /// octets.
    pub fn reservation(&self, class: MemoryClass, per_session_limit: u64) -> MemoryReservation {
        MemoryReservation {
            budget: self.clone(),
            class,
            limit: per_session_limit,
            reserved: 0,
        }
    }

    fn counter(&self, class: MemoryClass) -> &AtomicU64 {
        &self.0.classes[class.index()].0
    }

    /// Capacité de la classe `class`, compte tenu de l'usage de l'autre classe.
    fn capacity(&self, class: MemoryClass) -> u64 {
        let floor = self.0.limit / CLASS_FLOOR_SHARE;
        let other = self.used_by(class.other());
        self.0.limit.saturating_sub(other.max(floor)).max(floor)
    }
}

/// Mémoire réservée par une connexion, rendue au budget à sa libération.
#[derive(Debug)]
pub struct MemoryReservation {
    budget: MemoryBudget,
    class: MemoryClass,
    limit: u64,
    reserved: u64,
}

impl MemoryReservation {
    /// Porte la réservation à `bytes` octets au moins (arrondis au pas de 64 Kio). Faux si le
    /// budget de la classe ne le permet pas : la réservation est alors inchangée.
    pub fn reserve_to(&mut self, bytes: u64) -> bool {
        if bytes <= self.reserved {
            return true;
        }
        let delta = (bytes - self.reserved).next_multiple_of(MEMORY_GRANULE);
        let counter = self.budget.counter(self.class);
        let previous = counter.fetch_add(delta, Ordering::SeqCst);
        if previous.saturating_add(delta) <= self.budget.capacity(self.class) {
            self.reserved += delta;
            true
        } else {
            counter.fetch_sub(delta, Ordering::SeqCst);
            false
        }
    }

    /// Porte la réservation à `bytes` octets, dans la limite de la réservation et du budget.
    pub fn try_reserve_within_limit(&mut self, bytes: u64) -> Result<(), NetError> {
        if bytes <= self.limit && self.reserve_to(bytes) {
            Ok(())
        } else {
            Err(NetError::MemoryBudget)
        }
    }

    /// Portée de réservation : ce qu'elle ajoute est rendu à sa libération, sauf validation
    /// ([`ReservationScope::commit`]).
    pub fn scope(&mut self) -> ReservationScope<'_> {
        ReservationScope {
            start: self.reserved,
            reservation: self,
            committed: false,
        }
    }

    /// Ramène la réservation à `bytes` octets (arrondis au pas supérieur).
    pub fn shrink_to(&mut self, bytes: u64) {
        let keep = bytes.next_multiple_of(MEMORY_GRANULE);
        if keep < self.reserved {
            self.budget
                .counter(self.class)
                .fetch_sub(self.reserved - keep, Ordering::SeqCst);
            self.reserved = keep;
        }
    }

    /// Octets réservés.
    pub fn reserved(&self) -> u64 {
        self.reserved
    }

    /// Plafond de la réservation.
    pub fn limit(&self) -> u64 {
        self.limit
    }
}

impl Drop for MemoryReservation {
    fn drop(&mut self) {
        if self.reserved > 0 {
            self.budget
                .counter(self.class)
                .fetch_sub(self.reserved, Ordering::SeqCst);
        }
    }
}

/// Portée de réservation (voir [`MemoryReservation::scope`]).
#[derive(Debug)]
pub struct ReservationScope<'x> {
    reservation: &'x mut MemoryReservation,
    start: u64,
    committed: bool,
}

impl ReservationScope<'_> {
    /// Ajoute `extra` octets à la réservation de départ de la portée.
    pub fn try_reserve_extra(&mut self, extra: u64) -> Result<(), NetError> {
        self.reservation
            .try_reserve_within_limit(self.start.saturating_add(extra))
    }

    /// Garde ce que la portée a réservé.
    pub fn commit(mut self) {
        self.committed = true;
    }
}

impl Drop for ReservationScope<'_> {
    fn drop(&mut self) {
        if !self.committed {
            self.reservation.shrink_to(self.start);
        }
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used, clippy::panic)]
mod tests {
    use super::*;
    use proptest::prelude::*;

    const MIB: u64 = 1024 * 1024;

    #[test]
    fn reservations_are_rounded_to_the_granule_and_returned() {
        let budget = MemoryBudget::new(4 * MIB);
        let mut reservation = budget.reservation(MemoryClass::Read, 4 * MIB);
        assert!(reservation.reserve_to(1));
        assert_eq!(reservation.reserved(), MEMORY_GRANULE);
        assert!(reservation.reserve_to(MEMORY_GRANULE + 1));
        assert_eq!(reservation.reserved(), 2 * MEMORY_GRANULE);
        assert_eq!(budget.used(), 2 * MEMORY_GRANULE);
        reservation.shrink_to(1);
        assert_eq!(reservation.reserved(), MEMORY_GRANULE);
        drop(reservation);
        assert_eq!(budget.used(), 0);
    }

    #[test]
    fn per_session_limit_and_budget_are_enforced() {
        let budget = MemoryBudget::new(MIB);
        let mut small = budget.reservation(MemoryClass::Read, MEMORY_GRANULE);
        assert!(matches!(
            small.try_reserve_within_limit(2 * MEMORY_GRANULE),
            Err(NetError::MemoryBudget)
        ));
        assert_eq!(small.reserved(), 0);
        let mut big = budget.reservation(MemoryClass::Read, 2 * MIB);
        assert!(!big.reserve_to(2 * MIB));
        assert_eq!(budget.used(), 0);
        // Le quart du budget reste à l'autre classe : trois quarts pour cette classe
        assert!(!big.reserve_to(MIB));
        assert!(big.reserve_to(3 * MIB / 4));
        assert!(!small.reserve_to(1));
        let mut other = budget.reservation(MemoryClass::SmtpInbound, MIB);
        assert!(other.reserve_to(MIB / 4));
        assert_eq!(budget.used(), MIB);
    }

    #[test]
    fn each_class_keeps_a_quarter_of_the_budget() {
        let budget = MemoryBudget::new(4 * MIB);
        let mut smtp = budget.reservation(MemoryClass::SmtpInbound, 4 * MIB);
        // L'autre classe est vide : la réception peut prendre trois quarts, pas plus
        assert!(!smtp.reserve_to(3 * MIB + 1));
        assert!(smtp.reserve_to(3 * MIB));
        let mut read = budget.reservation(MemoryClass::Read, 4 * MIB);
        assert!(read.reserve_to(MIB));
        assert!(!read.reserve_to(MIB + 1));
        assert_eq!(budget.used(), 4 * MIB);
    }

    #[test]
    fn uncommitted_scope_is_rolled_back() {
        let budget = MemoryBudget::new(4 * MIB);
        let mut reservation = budget.reservation(MemoryClass::Read, 4 * MIB);
        assert!(reservation.reserve_to(MEMORY_GRANULE));
        {
            let mut scope = reservation.scope();
            scope.try_reserve_extra(MIB).expect("réservation");
        }
        assert_eq!(reservation.reserved(), MEMORY_GRANULE);
        {
            let mut scope = reservation.scope();
            scope.try_reserve_extra(MIB).expect("réservation");
            scope.commit();
        }
        assert_eq!(reservation.reserved(), MEMORY_GRANULE + MIB);
        assert_eq!(budget.used(), MEMORY_GRANULE + MIB);
    }

    proptest! {
        /// Quelles que soient les réservations, libérations et classes, la somme réservée ne
        /// dépasse jamais le budget et revient à zéro quand tout est libéré.
        #[test]
        fn reserved_total_never_exceeds_the_budget(
            limit in (1u64..64).prop_map(|n| n * MEMORY_GRANULE),
            operations in proptest::collection::vec((any::<bool>(), 0u64..(8 * MIB), 0usize..8), 1..200),
        ) {
            let budget = MemoryBudget::new(limit);
            let mut reservations: Vec<MemoryReservation> = (0..8)
                .map(|i| {
                    let class = if i % 2 == 0 { MemoryClass::Read } else { MemoryClass::SmtpInbound };
                    budget.reservation(class, u64::MAX)
                })
                .collect();
            for (grow, bytes, index) in operations {
                if grow {
                    reservations[index].reserve_to(bytes);
                } else {
                    reservations[index].shrink_to(bytes);
                }
                prop_assert!(budget.used() <= budget.limit());
            }
            drop(reservations);
            prop_assert_eq!(budget.used(), 0);
        }
    }
}
