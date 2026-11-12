//! Envois reprenables (`fn::storage_upload_*`).

use lyxal_surreal::SurrealValue;

use super::object::ObjectState;
use super::types::{StorageDatetime, StorageRecordId};

/// Nom des octets d'une partie sur le support.
pub type PartName = surrealdb::types::Uuid;

/// Paramètres de `fn::storage_upload_get` et `fn::storage_upload_part_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct UploadRefParams {
    /// Envoi (`storage_object:<clé>`).
    pub object: String,
}

/// État d'un envoi reprenable.
#[derive(Debug, Clone, SurrealValue)]
pub struct UploadStatus {
    /// Envoi : la fiche du fichier.
    pub id: StorageRecordId,
    /// État de la fiche : en attente tant que l'envoi est en cours, disponible une fois assemblé.
    pub state: ObjectState,
    /// Support qui porte les octets.
    pub backend: String,
    /// Emplacement du fichier final sur le support.
    pub path: String,
    /// Type MIME annoncé.
    pub declared_type: Option<String>,
    /// Taille annoncée du fichier, en octets.
    pub length: i64,
    /// Octets déjà reçus.
    pub offset: i64,
    /// Vrai si tous les octets sont reçus.
    pub complete: bool,
    /// Taille maximale acceptée, en octets.
    pub max_size: i64,
    /// Fin du délai de l'envoi (absente une fois le fichier disponible).
    pub expires_at: Option<StorageDatetime>,
}

/// Paramètres de `fn::storage_upload_part_add`.
#[derive(Debug, Clone, SurrealValue)]
pub struct UploadPartAddParams {
    /// Envoi (`storage_object:<clé>`).
    pub object: String,
    /// Position du premier octet de la partie.
    pub offset: i64,
    /// Taille de la partie, en octets.
    pub size: i64,
    /// Nom des octets de la partie sur le support.
    pub name: PartName,
}

/// Partie reçue d'un envoi.
#[derive(Debug, Clone, SurrealValue)]
pub struct UploadPart {
    /// Position du premier octet de la partie.
    pub offset: i64,
    /// Taille de la partie, en octets.
    pub size: i64,
    /// Nom des octets de la partie sur le support.
    pub name: PartName,
}

/// Résultat de `fn::storage_upload_part_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct UploadPartList {
    /// Parties, dans l'ordre du fichier.
    pub items: Vec<UploadPart>,
}

/// Paramètres de `fn::storage_upload_claim`.
#[derive(Debug, Clone, SurrealValue)]
pub struct UploadClaimParams {
    /// Envoi (`storage_object:<clé>`).
    pub object: String,
    /// Durée de la réservation, en secondes.
    pub seconds: i64,
    /// Jeton d'une réservation en cours, pour la prolonger ; absent pour réserver.
    pub claim: Option<PartName>,
}

/// Résultat de `fn::storage_upload_claim` : envoi complet dont l'assemblage est réservé.
#[derive(Debug, Clone, SurrealValue)]
pub struct ClaimedUpload {
    /// Envoi : la fiche du fichier.
    pub id: StorageRecordId,
    /// Support qui porte les octets.
    pub backend: String,
    /// Emplacement du fichier final sur le support.
    pub path: String,
    /// Type MIME annoncé.
    pub declared_type: Option<String>,
    /// Taille annoncée du fichier, en octets.
    pub length: i64,
    /// Taille maximale acceptée, en octets.
    pub max_size: i64,
    /// Jeton de la réservation : seul son détenteur termine ou abandonne l'envoi.
    pub claim: PartName,
}

/// Paramètres de `fn::storage_upload_release`.
#[derive(Debug, Clone, SurrealValue)]
pub struct UploadReleaseParams {
    /// Envoi (`storage_object:<clé>`).
    pub object: String,
    /// Jeton de la réservation.
    pub claim: PartName,
    /// Vrai pour abandonner l'envoi (contenu refusé) ; faux pour le laisser complet.
    pub abandon: bool,
}

/// Résultat de `fn::storage_upload_release`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct UploadReleased {
    /// Réservation rendue.
    pub released: bool,
    /// Envoi abandonné.
    pub abandoned: bool,
}

/// Résultat de `fn::storage_upload_ready_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct UploadReadyList {
    /// Envois complets à assembler, du plus ancien au plus récent.
    pub items: Vec<StorageRecordId>,
}
