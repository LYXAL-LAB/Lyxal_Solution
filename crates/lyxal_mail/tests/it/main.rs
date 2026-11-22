// SPDX-License-Identifier: AGPL-3.0-only

//! Point d'entrée unique des tests d'intégration du crate (un seul exécutable : chacun
//! embarque le moteur SurrealDB complet).

#![allow(clippy::unwrap_used, clippy::expect_used, clippy::panic)]

mod delivery;
mod support;
