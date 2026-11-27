// SPDX-License-Identifier: AGPL-3.0-only

//! Clés DKIM des domaines (`fn::mail_dkim_*`, lot 6 §9) : fiches publiques ; la clé privée est
//! rangée dans `lyxal_secrets`, jamais en base.

use lyxal_surreal::SurrealValue;

use super::types::{MailDatetime, MailRecordId};

/// Algorithme de signature DKIM.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "kebab-case")]
pub enum DkimAlgorithm {
    /// `rsa-sha256` (RFC 6376, 8301).
    RsaSha256,
    /// `ed25519-sha256` (RFC 8463).
    Ed25519Sha256,
}

/// État d'une clé DKIM.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum DkimKeyState {
    /// En attente de publication dans le DNS.
    Pending,
    /// Publiée : la clé signe.
    Active,
    /// Rotation en cours (lot 13).
    Retiring,
    /// Retirée (lot 13).
    Retired,
}

/// Paramètres de `fn::mail_dkim_key_create`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DkimKeyCreateParams {
    /// Domaine (`mail_domain:<clé>`).
    pub domain: String,
    /// Sélecteur (`lyx<aaaamm>r` ou `lyx<aaaamm>e`).
    pub selector: String,
    /// Algorithme.
    pub algorithm: DkimAlgorithm,
    /// Taille de la clé RSA (absente pour Ed25519).
    pub bits: Option<i64>,
    /// Clé publique (valeur `p=`, Base64).
    pub public_key: String,
    /// Chemin de la clé privée dans `lyxal_secrets` (`mail/dkim/<domaine>/<sélecteur>`).
    pub secret_path: String,
}

/// Fiche publique d'une clé DKIM (sans le chemin du secret).
#[derive(Debug, Clone, SurrealValue)]
pub struct DkimKey {
    /// Fiche.
    pub id: MailRecordId,
    /// Organisation du domaine.
    pub tenant: MailRecordId,
    /// Domaine de courrier.
    pub domain: MailRecordId,
    /// Sélecteur.
    pub selector: String,
    /// Algorithme.
    pub algorithm: DkimAlgorithm,
    /// Taille de la clé RSA.
    pub bits: Option<i64>,
    /// Clé publique (valeur `p=`).
    pub public_key: String,
    /// État.
    pub state: DkimKeyState,
    /// Dernier contrôle de l'enregistrement DNS.
    pub dns_checked_at: Option<MailDatetime>,
    /// Activation.
    pub activated_at: Option<MailDatetime>,
    /// Création.
    pub created_at: MailDatetime,
    /// Dernière modification.
    pub updated_at: MailDatetime,
}

/// Paramètres de `fn::mail_dkim_key_activate`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DkimKeyActivateParams {
    /// Clé (`mail_dkim_key:<clé>`).
    pub key: String,
}

/// Paramètres de `fn::mail_dkim_key_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DkimKeyListParams {
    /// Domaine (`mail_domain:<clé>`).
    pub domain: String,
}

/// Enregistrement DKIM à publier.
#[derive(Debug, Clone, SurrealValue)]
pub struct DkimRecord {
    /// Clé.
    pub key: MailRecordId,
    /// Sélecteur.
    pub selector: String,
    /// Algorithme.
    pub algorithm: DkimAlgorithm,
    /// État.
    pub state: DkimKeyState,
    /// Création.
    pub created_at: MailDatetime,
    /// Activation.
    pub activated_at: Option<MailDatetime>,
    /// Nom de l'enregistrement TXT (`<sélecteur>._domainkey.<domaine>`).
    pub dns_name: String,
    /// Valeur de l'enregistrement TXT (`v=DKIM1; k=…; p=…`).
    pub dns_value: String,
}

/// Résultat de `fn::mail_dkim_key_list`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DkimKeyPage {
    /// Clés du domaine, triées par sélecteur.
    pub items: Vec<DkimRecord>,
}

/// Paramètres de `fn::mail_dkim_signers`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DkimSignersParams {
    /// Domaines d'auteur du message (1 ou 2).
    pub domains: Vec<String>,
}

/// Clé active d'un domaine d'auteur.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct DkimSignerKey {
    /// Domaine.
    pub domain: String,
    /// Sélecteur.
    pub selector: String,
    /// Algorithme.
    pub algorithm: DkimAlgorithm,
    /// Chemin de la clé privée dans `lyxal_secrets`.
    pub secret_path: String,
}

/// Résultat de `fn::mail_dkim_signers`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DkimSigners {
    /// Clés actives.
    pub items: Vec<DkimSignerKey>,
}

/// Paramètres de `fn::mail_dkim_pending`.
#[derive(Debug, Clone, Copy, Default, SurrealValue)]
pub struct DkimPendingParams {
    /// Éléments au plus dans chaque liste (100 par défaut).
    pub limit: Option<i64>,
}

/// Domaine actif sans clé d'un algorithme.
#[derive(Debug, Clone, SurrealValue)]
pub struct DkimMissing {
    /// Domaine.
    pub domain: MailRecordId,
    /// Nom du domaine.
    pub name: String,
    /// Organisation.
    pub tenant: MailRecordId,
    /// Algorithme manquant.
    pub algorithm: DkimAlgorithm,
}

/// Clé en attente de publication.
#[derive(Debug, Clone, SurrealValue)]
pub struct DkimPendingKey {
    /// Clé.
    pub key: MailRecordId,
    /// Domaine.
    pub domain: MailRecordId,
    /// Nom du domaine.
    pub name: String,
    /// Sélecteur.
    pub selector: String,
    /// Algorithme.
    pub algorithm: DkimAlgorithm,
    /// Clé publique attendue dans le DNS.
    pub public_key: String,
    /// Création de la clé (sonde : domaine sans clé active depuis plus de 24 h).
    pub created_at: MailDatetime,
}

/// Résultat de `fn::mail_dkim_pending`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DkimPending {
    /// Domaines sans clé.
    pub missing: Vec<DkimMissing>,
    /// Clés en attente.
    pub pending: Vec<DkimPendingKey>,
}
