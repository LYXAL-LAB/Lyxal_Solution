//! Tâches du worker (`fn::secrets_purge_due`).

use lyxal_surreal::SurrealValue;

/// Paramètres de `fn::secrets_purge_due`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct PurgeDueParams {
    /// Secrets purgés au plus (1000 au plus).
    pub limit: Option<i64>,
}

/// Résultat de `fn::secrets_purge_due`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct PurgeReport {
    /// Secrets purgés.
    pub purged: i64,
    /// Tickets de lecture échus retirés.
    pub tickets_removed: i64,
}
