// SPDX-License-Identifier: AGPL-3.0-only

//! Avis de non-remise (DSN) : écriture ([`DsnBuilder`]) et lecture ([`parse_dsn`]) des rapports
//! `multipart/report; report-type=delivery-status` (RFC 6522), de leur partie
//! `message/delivery-status` (RFC 3464) et de la variante internationale
//! `message/global-delivery-status` (RFC 6533). Lot 6 du programme courrier, plan §3.3.
//!
//! Écrit pour Lyxal OS sur le modèle de Mox (`dsn/dsn.go` : `Compose` ; `dsn/parse.go` :
//! `Parse`, `Decode`, tolérances aux avis réels) ; aucun code n'est recopié.
//!
//! Le module ne décide d'aucun avis (quand, à qui : `lyxal_mail::dsn`) ; il n'envoie rien et ne
//! lit que ce que l'appelant lui remet. Les textes venus d'un serveur distant (`Remote-MTA`,
//! `Diagnostic-Code`) ne sont jamais recopiés hors de leur champ, et y sont assainis :
//! caractères de commande retirés, [`MAX_FIELD_BYTES`] octets par champ, lignes repliées sous
//! [`MAX_DSN_LINE_BYTES`] octets.
//!
//! Limites de lecture : partie `delivery-status` de [`MAX_REPORT_BYTES`] octets au plus (telle
//! que transmise), [`MAX_DSN_RECIPIENTS`] destinataires au plus.

mod build;
mod date;
mod encoding;
mod parse;

use time::OffsetDateTime;

use crate::smtp::{EnhancedStatus, Mailbox};

pub use build::{DsnBuildError, DsnBuilder};
pub use date::{format_date, parse_date};
pub use parse::{parse_dsn, DsnParseError};

/// Nombre maximal de destinataires d'un avis (écrit ou lu).
pub const MAX_DSN_RECIPIENTS: usize = 100;
/// Taille maximale de la partie `delivery-status` lue, telle que transmise (64 Kio).
pub const MAX_REPORT_BYTES: usize = 64 * 1024;
/// Taille maximale du message d'origine joint en entier (`RET=FULL`, 256 Kio) ; au-delà, ses
/// en-têtes seuls. Borne aussi les en-têtes joints.
pub const MAX_RETURNED_BYTES: usize = 256 * 1024;
/// Taille maximale de la valeur d'un champ, écrit ou lu.
pub const MAX_FIELD_BYTES: usize = 4_096;
/// Longueur maximale d'une ligne écrite, CRLF non compris (RFC 5322 §2.1.1).
pub const MAX_DSN_LINE_BYTES: usize = 998;

/// Action d'un destinataire (RFC 3464 §2.3.3).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum DsnAction {
    /// `failed` : échec définitif.
    Failed,
    /// `delayed` : retard, nouvelles tentatives.
    Delayed,
    /// `delivered` : remis.
    Delivered,
    /// `relayed` : transmis à un serveur qui ne fournit pas d'avis.
    Relayed,
    /// `expanded` : remis à une liste, puis redistribué.
    Expanded,
}

impl DsnAction {
    /// Valeur du champ `Action`.
    pub const fn name(&self) -> &'static str {
        match self {
            Self::Failed => "failed",
            Self::Delayed => "delayed",
            Self::Delivered => "delivered",
            Self::Relayed => "relayed",
            Self::Expanded => "expanded",
        }
    }

    /// Action nommée, sans égard à la casse.
    pub fn from_name(name: &str) -> Option<Self> {
        [
            Self::Failed,
            Self::Delayed,
            Self::Delivered,
            Self::Relayed,
            Self::Expanded,
        ]
        .into_iter()
        .find(|action| action.name().eq_ignore_ascii_case(name))
    }

    /// Code étendu par défaut d'un champ `Status` absent ou illisible (comme Mox).
    pub(crate) const fn default_status(&self) -> EnhancedStatus {
        match self {
            Self::Failed => EnhancedStatus::known(5, 0, 0),
            Self::Delayed => EnhancedStatus::known(4, 0, 0),
            Self::Delivered | Self::Relayed | Self::Expanded => EnhancedStatus::known(2, 0, 0),
        }
    }
}

/// Adresse d'un champ `Final-Recipient` ou `Original-Recipient` (RFC 3464 §2.3.1, §2.3.2) :
/// type (`rfc822`, `utf-8`...) et adresse **décodée**.
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub struct DsnAddress {
    /// Type d'adresse, en minuscules.
    pub address_type: String,
    /// Adresse décodée (séquences `\x{...}` de la RFC 6533 résolues).
    pub address: String,
}

impl DsnAddress {
    /// Adresse d'une boîte de l'enveloppe : `rfc822` si elle est ASCII, `utf-8` sinon.
    pub fn for_mailbox(mailbox: &Mailbox) -> Self {
        let address = mailbox.to_string();
        Self {
            address_type: if address.is_ascii() {
                "rfc822"
            } else {
                "utf-8"
            }
            .to_owned(),
            address,
        }
    }
}

/// Champ `Diagnostic-Code` (RFC 3464 §2.3.6) : type (`smtp`...) et texte.
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub struct DsnDiagnostic {
    /// Type de diagnostic, en minuscules (`smtp`).
    pub diagnostic_type: String,
    /// Texte : pour `smtp`, la réponse du serveur distant sur une ligne
    /// ([`crate::smtp::Response::diagnostic`]).
    pub text: String,
}

impl DsnDiagnostic {
    /// Diagnostic `smtp`.
    pub fn smtp(text: impl Into<String>) -> Self {
        Self {
            diagnostic_type: "smtp".to_owned(),
            text: text.into(),
        }
    }
}

/// Champs d'un destinataire (RFC 3464 §2.3).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DsnRecipient {
    /// `Original-Recipient` (paramètre `ORCPT`, décodé : [`crate::smtp::DsnOrcpt::decode`]).
    pub original_recipient: Option<DsnAddress>,
    /// `Final-Recipient`.
    pub final_recipient: DsnAddress,
    /// `Action`.
    pub action: DsnAction,
    /// `Status`.
    pub status: EnhancedStatus,
    /// `Remote-MTA` (nom, type `dns`).
    pub remote_mta: Option<String>,
    /// `Diagnostic-Code`.
    pub diagnostic: Option<DsnDiagnostic>,
    /// `Last-Attempt-Date`.
    pub last_attempt_date: Option<OffsetDateTime>,
    /// `Will-Retry-Until` (action `delayed`).
    pub will_retry_until: Option<OffsetDateTime>,
}

/// Rapport `delivery-status` lu.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DeliveryReport {
    /// Partie `message/global-delivery-status` (RFC 6533).
    pub international: bool,
    /// `Reporting-MTA` (nom, type `dns`), absent d'un avis mal formé.
    pub reporting_mta: Option<String>,
    /// `Original-Envelope-Id`.
    pub original_envelope_id: Option<String>,
    /// `Arrival-Date`.
    pub arrival_date: Option<OffsetDateTime>,
    /// Destinataires lisibles, dans l'ordre du rapport.
    pub recipients: Vec<DsnRecipient>,
    /// Groupes de champs de destinataire ignorés (sans `Final-Recipient` lisible ou sans
    /// `Action` connue).
    pub ignored_recipients: usize,
}
