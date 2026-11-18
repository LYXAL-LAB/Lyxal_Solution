//! Purge de `lyxal_auth` (`fn::auth_purge`, par paquets) : une opération rendue à l'appelant avec
//! son bilan. L'hôte la fait exécuter par `lyxal_scheduler` (tâche `auth.purge`).

use lyxal_runtime::worker::CancellationToken;
use lyxal_surreal::LyxalSurrealError;

use crate::models::{AuthPurgeParams, AuthPurgeResult};
use crate::store::AuthStore;

/// Purge : sessions expirées, parcours et codes expirés, jetons usés, compteurs d'échecs anciens,
/// invitations expirées.
pub struct AuthPurge {
    store: AuthStore,
    batch: i64,
}

impl AuthPurge {
    /// Purge par paquets de `batch` éléments, sur la session du store (session système de
    /// l'hôte).
    pub fn new(store: AuthStore, batch: i64) -> Self {
        Self { store, batch }
    }

    /// Une purge (paquets successifs tant qu'un paquet est plein), interrompue entre deux
    /// paquets si l'arrêt est demandé. Rend le bilan : total de chaque catégorie.
    pub async fn run(
        &self,
        cancellation: &CancellationToken,
    ) -> Result<AuthPurgeResult, LyxalSurrealError> {
        let mut report = AuthPurgeResult {
            sessions_expired: 0,
            flows: 0,
            refresh_tokens: 0,
            sessions: 0,
            login_failures: 0,
            invitations_expired: 0,
            pending_totp: 0,
            invitation_claims: 0,
            code_issuances: 0,
            identities_purged: 0,
            organizations_purged: 0,
        };
        while !cancellation.is_cancelled() {
            let result = self
                .store
                .purge(AuthPurgeParams {
                    limit: self.batch,
                    session_retention_days: None,
                })
                .await?;
            report.sessions_expired += result.sessions_expired;
            report.flows += result.flows;
            report.refresh_tokens += result.refresh_tokens;
            report.sessions += result.sessions;
            report.login_failures += result.login_failures;
            report.invitations_expired += result.invitations_expired;
            report.pending_totp += result.pending_totp;
            report.invitation_claims += result.invitation_claims;
            report.code_issuances += result.code_issuances;
            report.identities_purged += result.identities_purged;
            report.organizations_purged += result.organizations_purged;
            let largest = [
                result.flows,
                result.refresh_tokens,
                result.sessions,
                result.login_failures,
                result.pending_totp,
                result.invitation_claims,
                result.code_issuances,
                result.identities_purged,
                result.organizations_purged,
            ]
            .into_iter()
            .max()
            .unwrap_or(0);
            if largest < self.batch {
                break;
            }
        }
        Ok(report)
    }
}
