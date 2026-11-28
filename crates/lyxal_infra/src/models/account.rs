//! Comptes d'hébergeur (`fn::infra_account_*`). La clé d'API reste dans `lyxal_secrets` : un
//! compte n'en porte que le chemin.

use lyxal_surreal::SurrealValue;

use super::types::{InfraDatetime, InfraRecordId, InfraUuid};

/// État d'un compte d'hébergeur.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum AccountState {
    /// Utilisable.
    Active,
    /// Désactivé par l'administrateur (aucun appel).
    Disabled,
    /// Clé refusée par l'hébergeur.
    Failing,
}

/// Réglages Scaleway d'un compte.
#[derive(Debug, Clone, Default, PartialEq, SurrealValue)]
pub struct ScalewaySettings {
    /// Projet qui porte les zones (obligatoire à la création).
    pub project_id: Option<InfraUuid>,
    /// Organisation (facultative).
    pub organization_id: Option<InfraUuid>,
    /// Zone de disponibilité par défaut (`fr-par-1` à la création).
    pub default_zone: Option<String>,
    /// Région par défaut (`fr-par` à la création).
    pub default_region: Option<String>,
}

/// Paramètres de `fn::infra_account_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountCreateParams {
    /// Clé du compte (`snake_case`, 64 caractères au plus).
    pub key: String,
    /// Nom lisible.
    pub name: String,
    /// Fournisseur (`scaleway`, par défaut).
    pub provider: Option<String>,
    /// Chemin du secret dans `lyxal_secrets` (installation, sous `infra/`).
    pub credentials_path: String,
    /// Réglages du fournisseur.
    pub settings: ScalewaySettings,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres de `fn::infra_account_update` : un champ absent est conservé.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct AccountUpdateParams {
    /// Compte (`infra_account:<clé>`).
    pub account: String,
    /// Nom lisible.
    pub name: Option<String>,
    /// Nouveau chemin du secret (un essai est redemandé).
    pub credentials_path: Option<String>,
    /// Réglages fournis (remplacent les champs donnés).
    pub settings: Option<ScalewaySettings>,
    /// `Active` ou `Disabled`.
    pub state: Option<AccountState>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Paramètres des fonctions qui visent un compte (`_get`, `_delete`, `_test_request`).
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountRefParams {
    /// Compte (`infra_account:<clé>`).
    pub account: String,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

impl AccountRefParams {
    /// Paramètres pour le compte `account`.
    pub fn new(account: impl Into<String>) -> Self {
        Self {
            account: account.into(),
            language: None,
        }
    }
}

/// Paramètres de `fn::infra_account_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct AccountListParams {
    /// Filtre sur l'état.
    pub state: Option<AccountState>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Dernier essai d'un compte.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountTest {
    /// Date de l'essai.
    pub at: InfraDatetime,
    /// Clé acceptée et zones lues.
    pub ok: bool,
    /// Code `INFRA_*` de l'échec.
    pub code: Option<String>,
}

/// Zone visible du compte (rendue par le fournisseur au dernier essai).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct DiscoveredZone {
    /// Nom de la zone (A-label, minuscules).
    pub name: String,
    /// Statut chez le fournisseur.
    pub status: String,
}

/// Compte d'hébergeur, sans secret.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountResult {
    /// Compte.
    pub id: InfraRecordId,
    /// Clé.
    pub key: String,
    /// Nom lisible.
    pub name: String,
    /// Fournisseur.
    pub provider: String,
    /// Chemin du secret dans `lyxal_secrets`.
    pub credentials_path: String,
    /// Réglages du fournisseur.
    pub settings: ScalewaySettings,
    /// État.
    pub state: AccountState,
    /// Dernier essai.
    pub last_test: Option<AccountTest>,
    /// Essai demandé, pas encore fait.
    pub test_requested_at: Option<InfraDatetime>,
    /// Zones visibles au dernier essai réussi.
    pub discovered_zones: Vec<DiscoveredZone>,
    /// Nombre de zones rattachées (`fn::infra_account_get` seulement).
    pub zones: Option<i64>,
    /// Création.
    pub created_at: InfraDatetime,
    /// Dernière modification.
    pub updated_at: InfraDatetime,
}

/// Résultat de `fn::infra_account_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountListResult {
    /// Comptes, par clé.
    pub items: Vec<AccountResult>,
}

/// Résultat de `fn::infra_account_delete`.
#[derive(Debug, Clone, SurrealValue)]
pub struct AccountDeleted {
    /// Compte supprimé.
    pub deleted: InfraRecordId,
}
