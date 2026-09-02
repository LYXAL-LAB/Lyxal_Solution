use crate::lock::key::MigrationLockKey;
use crate::lock::node_id::NodeId;
use serde::{Deserialize, Serialize};

/// Représente un bail (lease) distribué sur une migration avec jeton de clôture (fencing token).
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct MigrationLease {
    /// Clé logique de la migration protégée.
    pub key: MigrationLockKey,
    /// Nœud propriétaire actuel du bail.
    pub owner: NodeId,
    /// Jeton de clôture / génération incrémentale monotone (fencing token anti-zombies).
    pub generation: u64,
    /// Horodatage Unix (secondes) d'acquisition initiale.
    pub acquired_at: u64,
    /// Horodatage Unix (secondes) du dernier renouvellement.
    pub renewed_at: u64,
    /// Horodatage Unix (secondes) d'expiration du bail.
    pub expires_at: u64,
}

impl MigrationLease {
    /// Indique si le bail est encore actif à l'instant donné.
    pub fn is_active_at(&self, timestamp: u64) -> bool {
        self.expires_at > timestamp
    }
}

/// Résultat d'une tentative d'acquisition de bail.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum AcquireLeaseResult {
    /// Le bail a été nouvellement acquis par l'instance appelante.
    Acquired(MigrationLease),
    /// L'instance appelante possède déjà un bail actif et valide sur cette clé.
    AlreadyOwned(MigrationLease),
    /// Le bail est actuellement détenu par une autre instance active.
    HeldByOther { owner: NodeId, expires_at: u64 },
    /// Le bail d'une instance précédente avait expiré et a été récupéré avec succès.
    RecoveredExpiredLease(MigrationLease),
}
