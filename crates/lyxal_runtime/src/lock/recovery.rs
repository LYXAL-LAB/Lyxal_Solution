use serde::{Deserialize, Serialize};

/// Politique de récupération du Runtime lorsqu'une migration est détectée dans un état interrompu (ex: `Applying` avec bail expiré).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
pub enum MigrationRecoveryPolicy {
    /// Politique stricte / conservatrice : refuse l'exécution automatique d'une migration interrompue
    /// pour éviter d'appliquer deux fois un script partiellement exécuté non idempotent.
    #[default]
    RequireManualIntervention,
    /// Politique permissive : autorise le rejeu automatique si et seulement si le checksum SHA-256 est strictement identique.
    AllowRetryIfChecksumMatches,
}
