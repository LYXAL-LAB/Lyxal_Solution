//! Cycle de vie (`fn::secrets_rotation_*`, `fn::secrets_due_*`) : rotations en quatre étapes,
//! échéances à signaler, clés d'organisation à faire tourner. Aucune valeur ne circule ici :
//! les erreurs sont des codes.

use lyxal_surreal::SurrealValue;
use std::collections::BTreeMap;

use super::types::{SecretsDatetime, SecretsRecordId};

/// État d'une rotation.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum RotationState {
    /// Démarrée : la nouvelle valeur reste à créer.
    Started,
    /// Nouvelle valeur écrite en version `pending`.
    Created,
    /// Nouvelle valeur activée chez le service extérieur.
    Installed,
    /// Nouvelle valeur vérifiée.
    Tested,
    /// Bascule faite : `current` sur la nouvelle version.
    Succeeded,
    /// Échec définitif ; la version courante est inchangée.
    Failed,
    /// Annulée.
    Cancelled,
}

impl RotationState {
    /// Vrai si la rotation est terminée (réussie, en échec ou annulée).
    pub fn is_terminal(self) -> bool {
        matches!(self, Self::Succeeded | Self::Failed | Self::Cancelled)
    }
}

/// Étape franchie, enregistrée par `fn::secrets_rotation_step`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "lowercase")]
pub enum RotationStep {
    /// Nouvelle valeur écrite (version `pending`).
    Created,
    /// Nouvelle valeur installée chez le service extérieur.
    Installed,
    /// Nouvelle valeur testée.
    Tested,
}

/// Rotation d'un secret (jamais de valeur : `last_error` est un code).
#[derive(Debug, Clone, SurrealValue)]
pub struct RotationRecord {
    /// Identifiant (`secrets_rotation:<clé>`).
    pub id: SecretsRecordId,
    /// Secret.
    pub secret: SecretsRecordId,
    /// Organisation (absente pour l'installation).
    pub tenant: Option<SecretsRecordId>,
    /// État.
    pub state: RotationState,
    /// Rotation d'urgence : la version courante a été désactivée au démarrage.
    pub emergency: bool,
    /// Motif.
    pub reason: Option<String>,
    /// Numéro de la nouvelle version (`pending`), à partir de l'étape `created`.
    pub pending_number: Option<i64>,
    /// Numéro de la version courante au démarrage.
    pub previous_number: Option<i64>,
    /// Échecs enregistrés.
    pub attempts: i64,
    /// Prochain essai planifié.
    pub next_attempt_at: Option<SecretsDatetime>,
    /// Réservée par un worker jusqu'à cette date.
    pub locked_until: Option<SecretsDatetime>,
    /// Jeton de la réservation en cours, à présenter à chaque étape (rendu par
    /// `fn::secrets_rotation_claim`).
    pub lease: Option<String>,
    /// Code de la dernière erreur.
    pub last_error: Option<String>,
    /// Identité ou application qui l'a démarrée.
    pub started_by: Option<String>,
    /// Démarrage.
    pub started_at: SecretsDatetime,
    /// Dernière modification.
    pub updated_at: SecretsDatetime,
    /// Fin.
    pub finished_at: Option<SecretsDatetime>,
    /// Étiquettes du secret après la bascule (`fn::secrets_rotation_finish` seulement).
    pub labels: Option<BTreeMap<String, i64>>,
}

/// Paramètres de `fn::secrets_rotation_begin`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RotationBeginParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Urgence : la version courante est désactivée tout de suite.
    pub emergency: Option<bool>,
    /// Motif (512 caractères au plus).
    pub reason: Option<String>,
}

/// Paramètres de `fn::secrets_rotation_step`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RotationStepParams {
    /// Rotation (`secrets_rotation:<clé>`).
    pub rotation: String,
    /// Jeton de la réservation (valide).
    pub lease: String,
    /// Étape franchie.
    pub step: RotationStep,
    /// Numéro de la version `pending` écrite (obligatoire pour `created`).
    pub pending_number: Option<i64>,
}

/// Paramètres de `fn::secrets_rotation_fail`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RotationFailParams {
    /// Rotation (`secrets_rotation:<clé>`).
    pub rotation: String,
    /// Jeton de la réservation (valide).
    pub lease: String,
    /// Code de l'erreur (jamais de valeur).
    pub code: String,
    /// Nouvel essai permis (défaut vrai) ; faux : échec définitif.
    pub retry: Option<bool>,
}

/// Paramètres de `fn::secrets_rotation_claim`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct RotationClaimParams {
    /// Une rotation précise ; absente : les rotations en cours dont l'essai est échu.
    pub rotation: Option<String>,
    /// Rotations réservées au plus (100 au plus).
    pub limit: Option<i64>,
    /// Durée de la réservation, en secondes (10 à 3600, défaut 300).
    pub lease_seconds: Option<i64>,
}

/// Résultat de `fn::secrets_rotation_claim`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RotationClaimed {
    /// Rotations réservées.
    pub items: Vec<RotationRecord>,
}

/// Paramètres de `fn::secrets_rotation_finish`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RotationLeaseParams {
    /// Rotation (`secrets_rotation:<clé>`).
    pub rotation: String,
    /// Jeton de la réservation (valide).
    pub lease: String,
}

/// Paramètres de `fn::secrets_rotation_cancel` (sans réservation).
#[derive(Debug, Clone, SurrealValue)]
pub struct RotationRefParams {
    /// Rotation (`secrets_rotation:<clé>`).
    pub rotation: String,
}

/// Paramètres de `fn::secrets_rotation_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RotationGetParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Rotations rendues au plus (100 au plus).
    pub limit: Option<i64>,
}

/// Résultat de `fn::secrets_rotation_get`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RotationList {
    /// Rotation en cours.
    pub active: Option<RotationRecord>,
    /// Rotations, les plus récentes d'abord.
    pub items: Vec<RotationRecord>,
}

/// Paramètres de `fn::secrets_rotation_check_record`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RotationCheckParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Résultat de l'essai.
    pub ok: bool,
    /// Code de l'erreur si l'essai a échoué.
    pub code: Option<String>,
}

/// Résultat de `fn::secrets_rotation_check_record`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RotationCheckResult {
    /// Date de l'essai.
    pub checked_at: SecretsDatetime,
    /// Résultat.
    pub ok: bool,
    /// Code de l'erreur.
    pub code: Option<String>,
}

/// Paramètres de `fn::secrets_due_list`.
#[derive(Debug, Clone, Default, SurrealValue)]
pub struct DueListParams {
    /// Éléments par liste (1000 au plus).
    pub limit: Option<i64>,
}

/// Secret dont l'échéance est proche ou passée.
#[derive(Debug, Clone, SurrealValue)]
pub struct DueSecret {
    /// Secret.
    pub id: SecretsRecordId,
    /// Organisation.
    pub tenant: Option<SecretsRecordId>,
    /// Chemin.
    pub path: String,
    /// Échéance.
    pub expires_at: SecretsDatetime,
}

/// Secret dont la date de rotation est passée.
#[derive(Debug, Clone, SurrealValue)]
pub struct DueRotation {
    /// Secret.
    pub id: SecretsRecordId,
    /// Organisation.
    pub tenant: Option<SecretsRecordId>,
    /// Chemin.
    pub path: String,
    /// Type.
    pub kind: String,
    /// Rotation prévue.
    pub next_rotation_at: SecretsDatetime,
}

/// Clé d'organisation plus ancienne que la période de rotation de sa portée.
#[derive(Debug, Clone, SurrealValue)]
pub struct DueTenantKey {
    /// Organisation (absente pour l'installation).
    pub tenant: Option<SecretsRecordId>,
    /// Portée : `installation` ou clé de l'organisation.
    pub scope_key: String,
    /// Clé active.
    pub key_id: String,
    /// Création.
    pub created_at: SecretsDatetime,
}

/// Résultat de `fn::secrets_due_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DueList {
    /// Échéance dans le délai d'alerte, pas encore signalée.
    pub expiring: Vec<DueSecret>,
    /// Échéance passée, pas encore signalée.
    pub expired: Vec<DueSecret>,
    /// Date de rotation passée, rappel pas encore envoyé.
    pub rotation_due: Vec<DueRotation>,
    /// Clés d'organisation à faire tourner.
    pub tenant_keys_due: Vec<DueTenantKey>,
}

/// Échéance signalée par `fn::secrets_due_mark`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum DueKind {
    /// Échéance proche.
    Expiring,
    /// Échéance passée.
    Expired,
    /// Rotation due.
    RotationDue,
}

/// Paramètres de `fn::secrets_due_mark`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DueMarkParams {
    /// Secret (`secrets_secret:<clé>`).
    pub secret: String,
    /// Échéance signalée.
    pub kind: DueKind,
}

/// Résultat de `fn::secrets_due_mark`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct DueMarkResult {
    /// Alerte posée (faux : déjà signalée, ou la situation ne tient plus).
    pub marked: bool,
}
