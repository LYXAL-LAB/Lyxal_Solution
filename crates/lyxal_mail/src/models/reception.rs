// SPDX-License-Identifier: AGPL-3.0-only

//! Réception (`fn::mail_recipient_resolve`, `fn::mail_delivery_*`) : résolution d'un
//! destinataire, remise groupée et idempotente dans un compte, résultats des contrôles d'un
//! message reçu.

use lyxal_surreal::SurrealValue;

use super::message::MessageEnvelope;
use super::types::{MailDatetime, MailRecordId, MailValue};
use crate::auth::{DkimResult, DmarcResult, IprevResult, SpfResult};

/// Paramètres de `fn::mail_recipient_resolve`.
#[derive(Debug, Clone, SurrealValue)]
pub struct RecipientResolveParams {
    /// Adresse du destinataire (ASCII, domaine en forme ASCII), ou `postmaster` sans domaine.
    pub address: String,
}

/// Compte qui reçoit un destinataire résolu.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct RecipientAccount {
    /// Compte actif.
    pub account: MailRecordId,
    /// Quota du compte atteint : une remise serait refusée.
    pub quota_full: bool,
}

/// Sorte d'un destinataire résolu.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum RecipientKind {
    /// Boîtes de comptes (adresse, alias, attrape-tout, postmaster).
    Mailbox,
    /// Adresse de retour à jeton d'un envoi (`rp=<jeton>@<domaine>`, lot 6 §11) : seuls les
    /// avis de non-remise et réponses automatiques de cet envoi y arrivent.
    Return,
}

/// Résultat de `fn::mail_recipient_resolve`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ResolvedRecipient {
    /// Sorte : boîtes de comptes, ou adresse de retour d'un envoi.
    pub kind: RecipientKind,
    /// Adresse inscrite qui a servi (adresse demandée pour un attrape-tout).
    pub address: String,
    /// Domaine de courrier (forme ASCII).
    pub domain: String,
    /// Organisation du domaine.
    pub tenant: MailRecordId,
    /// Taille maximale d'un message de l'organisation, en octets.
    pub max_message_bytes: i64,
    /// Comptes actifs qui reçoivent le message (alias développé), triés ; vide pour une
    /// adresse de retour.
    pub accounts: Vec<RecipientAccount>,
    /// Alias : adresses extérieures qui reçoivent aussi le message (transfert, lot 6 §13).
    pub forward_to: Vec<String>,
    /// Réglage du domaine contre la rétrodiffusion (lot 6 §11).
    pub backscatter_protection: bool,
    /// Adresse de retour : envoi auquel elle appartient.
    pub submission: Option<MailRecordId>,
    /// Adresse de retour : origine de l'envoi (`submission`, `module`, `forward`, `dsn`).
    pub origin: Option<String>,
    /// Adresse de retour : compte expéditeur d'un dépôt authentifié.
    pub account: Option<MailRecordId>,
}

/// Résultats des contrôles d'un message à sa réception, sans domaine ni adresse : mots de
/// résultat de la RFC 8601, antivirus, anti-spam, TLS.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct Reception {
    /// SPF : `none`, `neutral`, `pass`, `fail`, `softfail`, `temperror`, `permerror`.
    pub spf: String,
    /// DKIM : `none`, `pass`, `fail`, `neutral`, `policy`, `temperror`, `permerror`.
    pub dkim: String,
    /// DMARC : `none`, `pass`, `fail`, `temperror`, `permerror`.
    pub dmarc: String,
    /// Nom inverse : `pass`, `fail`, `temperror`, `permerror` ; `none` pour une remise sans
    /// connexion réseau (route locale, avis de non-remise, lot 6).
    pub iprev: String,
    /// Antivirus : `clean`, ou `not_scanned` (aucun antivirus configuré).
    pub antivirus: String,
    /// Verdict anti-spam (`none` jusqu'au lot 11).
    pub spam: String,
    /// Reçu sous TLS.
    pub tls: bool,
}

impl Reception {
    /// Résultats d'un message reçu : contrôles d'authenticité, antivirus (`scanned` : analysé
    /// et sain ; faux : aucun antivirus configuré) et état TLS de la session.
    pub fn new(
        spf: SpfResult,
        dkim: DkimResult,
        dmarc: DmarcResult,
        iprev: IprevResult,
        scanned: bool,
        tls: bool,
    ) -> Self {
        Self {
            spf: spf.as_str().to_string(),
            dkim: dkim.as_str().to_string(),
            dmarc: dmarc.as_str().to_string(),
            iprev: iprev.as_str().to_string(),
            antivirus: if scanned { "clean" } else { "not_scanned" }.to_string(),
            spam: "none".to_string(),
            tls,
        }
    }
}

/// Paramètres de `fn::mail_delivery_begin`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DeliveryBeginParams {
    /// Compte (`mail_account:<clé>`).
    pub account: String,
    /// Taille du message en clair, en octets.
    pub size: i64,
    /// Empreinte d'idempotence de la remise (BLAKE3 en hexadécimal, 64 caractères).
    pub delivery_key: String,
}

/// Résultat de `fn::mail_delivery_begin` : contenu réservé, ou message déjà remis à ce compte.
#[derive(Debug, Clone, PartialEq, SurrealValue)]
#[surreal(untagged)]
pub enum DeliveryReservation {
    /// Contenu réservé : fichier à écrire dans le bucket chiffré `lyxal-mail` de l'organisation.
    Reserved {
        /// Contenu `pending`.
        content: MailRecordId,
        /// Clé du fichier (`<compte>/<UUID v7>.eml`, sans donnée personnelle).
        storage_key: String,
    },
    /// Message déjà remis à ce compte dans les 7 jours : rien à écrire.
    Duplicate {
        /// Fiche inscrite par la première remise.
        message: MailRecordId,
    },
}

/// Dossier de remise d'un message reçu.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, SurrealValue)]
#[surreal(untagged, rename_all = "snake_case")]
pub enum DeliveryRole {
    /// Boîte de réception.
    #[default]
    Inbox,
    /// Dossier « Junk » (quarantaine demandée par la politique DMARC de l'expéditeur) ; absent
    /// du compte : boîte de réception.
    Junk,
}

/// Un message d'un lot de `fn::mail_delivery_commit`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DeliveryItem {
    /// Contenu réservé par `fn::mail_delivery_begin` (`mail_content:<clé>`).
    pub content: String,
    /// Fichier écrit par `lyxal_storage` (`storage_object:<clé>`).
    pub object: String,
    /// Dossier de remise.
    pub role: DeliveryRole,
    /// Date interne.
    pub received_at: MailDatetime,
    /// Empreinte d'idempotence de la remise.
    pub delivery_key: String,
    /// `Message-ID`, sans chevrons.
    pub message_id: Option<String>,
    /// `In-Reply-To`, sans chevrons.
    pub in_reply_to: Vec<String>,
    /// `References`, sans chevrons.
    pub references: Vec<String>,
    /// Sujet de base.
    pub base_subject: Option<String>,
    /// Avis de non-remise : pas de rapprochement de fil par le sujet.
    pub is_report: bool,
    /// Enveloppe.
    pub envelope: MessageEnvelope,
    /// Structure MIME.
    pub structure: MailValue,
    /// Le message porte au moins une pièce jointe.
    pub has_attachment: bool,
    /// Résultats des contrôles à la réception.
    pub reception: Reception,
}

/// Paramètres de `fn::mail_delivery_commit` : 1 à 32 messages remis à un même compte.
#[derive(Debug, Clone, SurrealValue)]
pub struct DeliveryCommitParams {
    /// Compte (`mail_account:<clé>`).
    pub account: String,
    /// Messages du lot, dans l'ordre d'inscription.
    pub items: Vec<DeliveryItem>,
}

/// Erreur d'un élément d'un lot (définition `MAIL_*` résolue).
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct DeliveryItemError {
    /// Code `MAIL_*`.
    pub code: String,
    /// L'élément peut réussir plus tard sans changement.
    pub retryable: bool,
}

/// Résultat d'un élément de `fn::mail_delivery_commit` : message inscrit (ou déjà remis), ou
/// erreur de cet élément seulement.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct DeliveryItemResult {
    /// Message inscrit, ou déjà remis.
    pub message: Option<MailRecordId>,
    /// UID dans le dossier (absent si le message déjà remis n'existe plus).
    pub uid: Option<i64>,
    /// Dossier (absent si le message déjà remis n'existe plus).
    pub mailbox: Option<MailRecordId>,
    /// Message déjà remis : rien n'a été inscrit.
    #[surreal(default)]
    pub duplicate: bool,
    /// Erreur de l'élément ; les autres éléments du lot ne sont pas annulés.
    pub error: Option<DeliveryItemError>,
}

/// Résultat de `fn::mail_delivery_commit`.
#[derive(Debug, Clone, SurrealValue)]
pub struct DeliveryCommitResult {
    /// Résultats, dans l'ordre du lot.
    pub items: Vec<DeliveryItemResult>,
}

/// Résultat de `fn::mail_delivery_purge`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, SurrealValue)]
pub struct DeliveriesPurged {
    /// Fiches d'idempotence échues retirées.
    pub removed: i64,
}
