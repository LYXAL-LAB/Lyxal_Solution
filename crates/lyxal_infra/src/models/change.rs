//! Journal chaîné des changements (`fn::infra_change_list`, `fn::infra_change_verify`).

use lyxal_surreal::{SurrealValue, Value};

use super::types::{ChangeAction, InfraDatetime, InfraRecordId};

/// État d'une entrée du journal.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum ChangeState {
    /// Intention notée avant l'appel.
    Sent,
    /// Écriture faite.
    Done,
    /// Écriture refusée.
    Failed,
    /// Constat ou décision.
    Noted,
}

/// Entrée du journal.
#[derive(Debug, Clone, SurrealValue)]
pub struct ChangeEntry {
    /// Entrée.
    pub id: InfraRecordId,
    /// Rang dans la chaîne.
    pub rank: i64,
    /// Zone (clé opaque).
    pub zone: Option<InfraRecordId>,
    /// Enregistrement voulu concerné.
    pub record: Option<InfraRecordId>,
    /// Action.
    pub action: ChangeAction,
    /// État.
    pub state: ChangeState,
    /// Valeur avant (jamais de secret).
    pub before: Value,
    /// Valeur après (jamais de secret).
    pub after: Value,
    /// Auteur : identité, application ou `system`.
    pub actor: String,
    /// Statut HTTP rendu par le fournisseur.
    pub provider_status: Option<i64>,
    /// Code `INFRA_*` de l'échec.
    pub code: Option<String>,
    /// Empreinte de l'entrée.
    pub entry_hash: String,
    /// Date de l'entrée.
    pub created_at: InfraDatetime,
}

/// Paramètres de `fn::infra_change_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct ChangeListParams {
    /// Filtre sur la zone.
    pub zone: Option<String>,
    /// Filtre sur l'enregistrement voulu.
    pub record: Option<String>,
    /// Filtre sur l'action.
    pub action: Option<ChangeAction>,
    /// Taille de page (500 au plus).
    pub limit: Option<i64>,
    /// Début de la page.
    pub start: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::infra_change_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ChangeListResult {
    /// Entrées de la page, les plus récentes d'abord.
    pub items: Vec<ChangeEntry>,
    /// Nombre total.
    pub total: i64,
}

/// Paramètres de `fn::infra_change_verify`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct ChangeVerifyParams {
    /// Premier rang vérifié (défaut : plus ancienne entrée conservée).
    pub from_rank: Option<i64>,
    /// Nombre d'entrées (10 000 au plus).
    pub limit: Option<i64>,
    /// Langue des messages d'erreur.
    pub language: Option<String>,
}

/// Résultat de `fn::infra_change_verify`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ChangeVerifyResult {
    /// Chaîne intacte.
    pub valid: bool,
    /// Entrées vérifiées.
    pub checked: i64,
    /// Premier rang vérifié.
    pub from_rank: i64,
    /// Premier rang en défaut.
    pub broken_at: Option<i64>,
    /// La dernière entrée est celle de la tête de chaîne.
    pub head_matches: bool,
    /// La plage va jusqu'au bout du journal.
    pub complete: bool,
}
