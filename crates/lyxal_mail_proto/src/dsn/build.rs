// SPDX-License-Identifier: AGPL-3.0-only

//! Écriture d'un avis (RFC 6522, 3464, 6533), sur le modèle de Mox (`dsn/dsn.go`, `Compose`).
//!
//! Trois parties : texte lisible (français puis anglais, quoted-printable UTF-8), rapport
//! `message/delivery-status` (ou `message/global-delivery-status`), puis les en-têtes du
//! message d'origine (`RET=HDRS`) ou le message entier (`RET=FULL`, [`MAX_RETURNED_BYTES`] au
//! plus ; au-delà, les en-têtes seuls). Le texte lisible ne reprend que nos propres données
//! (adresses, codes étendus, dates) : aucun texte venu d'un serveur distant.

use std::fmt::Write as _;
use std::hash::{DefaultHasher, Hash, Hasher};

use time::OffsetDateTime;

use super::date::format_date;
use super::encoding::{encode_quoted_printable, sanitize_field, write_field};
use super::{DsnAction, DsnRecipient, MAX_DSN_RECIPIENTS, MAX_RETURNED_BYTES};
use crate::smtp::xtext::{encode_utf8_addr_unitext, encode_utf8_addr_xtext};
use crate::smtp::{DsnRet, Mailbox};

/// Tentatives de choix d'une frontière MIME absente du message d'origine.
const BOUNDARY_ATTEMPTS: u64 = 16;
/// Longueur maximale d'un identifiant de message, sans chevrons.
const MAX_MESSAGE_ID_BYTES: usize = 250;

/// Avis impossible à écrire. Aucune donnée n'y figure.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum DsnBuildError {
    /// Aucun destinataire.
    #[error("avis sans destinataire")]
    NoRecipient,
    /// Plus de [`MAX_DSN_RECIPIENTS`] destinataires.
    #[error("avis de plus de {MAX_DSN_RECIPIENTS} destinataires")]
    TooManyRecipients,
    /// `Reporting-MTA` qui n'est pas un nom d'hôte ASCII.
    #[error("nom du serveur invalide")]
    InvalidReportingMta,
    /// Identifiant de message vide, trop long, ou avec un caractère hors de l'ASCII visible,
    /// `<` ou `>`.
    #[error("identifiant de message invalide")]
    InvalidMessageId,
    /// Expéditeur ou destinataire de l'avis non ASCII hors d'un avis international.
    #[error("adresse non ASCII hors d'un avis international")]
    NonAsciiAddress,
    /// `Original-Envelope-Id` hors de l'ASCII imprimable.
    #[error("identifiant d'enveloppe invalide")]
    InvalidEnvelopeId,
    /// Aucune frontière MIME absente du message d'origine n'a été trouvée.
    #[error("frontière MIME introuvable")]
    BoundaryCollision,
}

/// Avis à écrire.
#[derive(Clone, Copy, Debug)]
pub struct DsnBuilder<'a> {
    /// Nom du serveur qui produit l'avis (`Reporting-MTA: dns; <nom>`), ASCII.
    pub reporting_mta: &'a str,
    /// Expéditeur de l'avis (`MAILER-DAEMON@<nom>`) ; l'enveloppe de l'avis est `<>`.
    pub from: &'a Mailbox,
    /// Destinataire de l'avis (expéditeur d'origine).
    pub to: &'a Mailbox,
    /// `Message-ID` de l'avis, sans chevrons.
    pub message_id: &'a str,
    /// `Date` de l'avis.
    pub date: OffsetDateTime,
    /// `Message-ID` du message d'origine, sans chevrons (`In-Reply-To`, `References` : l'avis
    /// se range dans le fil du message).
    pub original_message_id: Option<&'a str>,
    /// L'envoi d'origine exigeait `SMTPUTF8` : variante internationale (RFC 6533).
    pub international: bool,
    /// `Original-Envelope-Id` (paramètre `ENVID` décodé).
    pub original_envelope_id: Option<&'a str>,
    /// `Arrival-Date` : arrivée du message d'origine.
    pub arrival_date: OffsetDateTime,
    /// Destinataires de l'avis.
    pub recipients: &'a [DsnRecipient],
    /// Contenu joint : en-têtes (`RET=HDRS`, défaut de la décision E22) ou message entier.
    pub ret: DsnRet,
    /// Message d'origine tel qu'envoyé (CRLF) ; vide : aucune troisième partie.
    pub original: &'a [u8],
}

impl DsnBuilder<'_> {
    /// Écrit l'avis (message complet, lignes CRLF).
    pub fn build(&self) -> Result<Vec<u8>, DsnBuildError> {
        self.check()?;
        let attached = self.attached();
        let boundary = self.boundary(attached.map(|(_, bytes)| bytes))?;
        let mut out = Vec::with_capacity(4_096 + attached.map_or(0, |(_, bytes)| bytes.len()));
        self.headers(&mut out, &boundary);

        part_start(&mut out, &boundary);
        out.extend_from_slice(
            b"Content-Type: text/plain; charset=utf-8\r\n\
              Content-Transfer-Encoding: quoted-printable\r\n\r\n",
        );
        encode_quoted_printable(&self.human_text(), &mut out);

        part_start(&mut out, &boundary);
        if self.international {
            out.extend_from_slice(
                b"Content-Type: message/global-delivery-status\r\n\
                  Content-Transfer-Encoding: 8bit\r\n\r\n",
            );
        } else {
            out.extend_from_slice(
                b"Content-Type: message/delivery-status\r\n\
                  Content-Transfer-Encoding: 7bit\r\n\r\n",
            );
        }
        self.status_fields(&mut out);

        if let Some((content_type, bytes)) = attached {
            part_start(&mut out, &boundary);
            let encoding = if bytes.is_ascii() { "7bit" } else { "8bit" };
            let _ = write!(
                Fields(&mut out),
                "Content-Type: {content_type}\r\nContent-Transfer-Encoding: {encoding}\r\n\r\n"
            );
            out.extend_from_slice(bytes);
        }
        // Le CRLF qui précède une frontière lui appartient (RFC 2046 §5.1.1) : le contenu joint
        // garde ses octets exacts.
        out.extend_from_slice(b"\r\n--");
        out.extend_from_slice(boundary.as_bytes());
        out.extend_from_slice(b"--\r\n");
        Ok(out)
    }

    fn check(&self) -> Result<(), DsnBuildError> {
        if self.recipients.is_empty() {
            return Err(DsnBuildError::NoRecipient);
        }
        if self.recipients.len() > MAX_DSN_RECIPIENTS {
            return Err(DsnBuildError::TooManyRecipients);
        }
        if !is_hostname(self.reporting_mta) {
            return Err(DsnBuildError::InvalidReportingMta);
        }
        if !is_message_id(self.message_id)
            || self
                .original_message_id
                .is_some_and(|id| !is_message_id(id))
        {
            return Err(DsnBuildError::InvalidMessageId);
        }
        if !self.international && !(self.from.is_ascii() && self.to.is_ascii()) {
            return Err(DsnBuildError::NonAsciiAddress);
        }
        if self
            .original_envelope_id
            .is_some_and(|id| id.is_empty() || !id.bytes().all(|b| (b' '..=b'~').contains(&b)))
        {
            return Err(DsnBuildError::InvalidEnvelopeId);
        }
        Ok(())
    }

    /// Type et octets de la troisième partie.
    fn attached(&self) -> Option<(&'static str, &[u8])> {
        if self.original.is_empty() {
            return None;
        }
        let full = self.ret == DsnRet::Full && self.original.len() <= MAX_RETURNED_BYTES;
        if full {
            let content_type = if self.international {
                "message/global"
            } else {
                "message/rfc822"
            };
            return Some((content_type, self.original));
        }
        let content_type = if self.international {
            "message/global-headers"
        } else {
            "text/rfc822-headers"
        };
        Some((content_type, header_block(self.original)))
    }

    /// Frontière absente du contenu joint (le texte quoted-printable et le rapport ne peuvent
    /// pas contenir `=_`).
    fn boundary(&self, attached: Option<&[u8]>) -> Result<String, DsnBuildError> {
        for attempt in 0..BOUNDARY_ATTEMPTS {
            let mut hasher = DefaultHasher::new();
            self.message_id.hash(&mut hasher);
            attempt.hash(&mut hasher);
            let boundary = format!("=_lyxal-dsn-{:016x}", hasher.finish());
            let delimiter = format!("--{boundary}");
            let collides = attached.is_some_and(|bytes| {
                bytes
                    .windows(delimiter.len())
                    .any(|window| window == delimiter.as_bytes())
            });
            if !collides {
                return Ok(boundary);
            }
        }
        Err(DsnBuildError::BoundaryCollision)
    }

    fn headers(&self, out: &mut Vec<u8>, boundary: &str) {
        let subject = match self.summary_action() {
            DsnAction::Failed => "Avis de non-remise / Delivery Status Notification (Failure)",
            DsnAction::Delayed => "Avis de retard / Delivery Status Notification (Delay)",
            DsnAction::Delivered | DsnAction::Expanded => {
                "Avis de remise / Delivery Status Notification (Success)"
            }
            DsnAction::Relayed => "Avis de transmission / Delivery Status Notification (Relayed)",
        };
        let mut fields = Fields(out);
        let _ = write!(
            fields,
            "From: Mail Delivery System <{}>\r\nTo: <{}>\r\nSubject: {subject}\r\nDate: {}\r\n\
             Message-ID: <{}>\r\n",
            self.from,
            self.to,
            format_date(self.date),
            self.message_id,
        );
        if let Some(original) = self.original_message_id {
            let _ = write!(
                fields,
                "In-Reply-To: <{original}>\r\nReferences: <{original}>\r\n"
            );
        }
        let _ = write!(
            fields,
            "Auto-Submitted: auto-replied\r\nMIME-Version: 1.0\r\n\
             Content-Type: multipart/report; report-type=delivery-status;\r\n\
             \tboundary=\"{boundary}\"\r\n\r\n\
             This is a delivery status notification (RFC 3464).\r\n"
        );
    }

    /// Action qui donne le sujet : échec, puis retard, puis remise, puis transmission.
    fn summary_action(&self) -> DsnAction {
        let has = |action: DsnAction| self.recipients.iter().any(|r| r.action == action);
        [
            DsnAction::Failed,
            DsnAction::Delayed,
            DsnAction::Delivered,
            DsnAction::Expanded,
        ]
        .into_iter()
        .find(|&action| has(action))
        .unwrap_or(DsnAction::Relayed)
    }

    fn status_fields(&self, out: &mut Vec<u8>) {
        let international = self.international;
        write_field(
            out,
            "Reporting-MTA",
            &format!("dns; {}", self.reporting_mta),
        );
        if let Some(envid) = self.original_envelope_id {
            write_field(out, "Original-Envelope-Id", envid);
        }
        write_field(out, "Arrival-Date", &format_date(self.arrival_date));
        for recipient in self.recipients {
            out.extend_from_slice(b"\r\n");
            if let Some(original) = &recipient.original_recipient {
                write_field(
                    out,
                    "Original-Recipient",
                    &address_value(&original.address_type, &original.address, international),
                );
            }
            let last = &recipient.final_recipient;
            write_field(
                out,
                "Final-Recipient",
                &address_value(&last.address_type, &last.address, international),
            );
            write_field(out, "Action", recipient.action.name());
            write_field(out, "Status", &recipient.status.to_string());
            if let Some(remote) = &recipient.remote_mta {
                let remote = sanitize_field(remote, false);
                write_field(out, "Remote-MTA", &format!("dns; {remote}"));
            }
            if let Some(diagnostic) = &recipient.diagnostic {
                let kind = sanitize_token(&diagnostic.diagnostic_type);
                let text = sanitize_field(&diagnostic.text, international);
                write_field(out, "Diagnostic-Code", &format!("{kind}; {text}"));
            }
            if let Some(date) = recipient.last_attempt_date {
                write_field(out, "Last-Attempt-Date", &format_date(date));
            }
            if let Some(date) = recipient.will_retry_until {
                write_field(out, "Will-Retry-Until", &format_date(date));
            }
        }
    }

    fn human_text(&self) -> String {
        let mut fr = format!(
            "Ceci est un message automatique du serveur de courrier {}.\n",
            self.reporting_mta
        );
        let mut en = format!(
            "This is an automatically generated message from the mail server {}.\n",
            self.reporting_mta
        );
        for action in [
            DsnAction::Failed,
            DsnAction::Delayed,
            DsnAction::Delivered,
            DsnAction::Relayed,
            DsnAction::Expanded,
        ] {
            let recipients: Vec<&DsnRecipient> = self
                .recipients
                .iter()
                .filter(|r| r.action == action)
                .collect();
            if recipients.is_empty() {
                continue;
            }
            let (intro_fr, intro_en) = match action {
                DsnAction::Failed => (
                    "Votre message n'a pas pu être remis aux destinataires suivants :",
                    "Your message could not be delivered to the following recipients:",
                ),
                DsnAction::Delayed => (
                    "Votre message n'a pas encore pu être remis aux destinataires suivants ; \
                     le serveur continue d'essayer :",
                    "Your message has not yet been delivered to the following recipients; \
                     the server keeps trying:",
                ),
                DsnAction::Delivered => (
                    "Votre message a été remis aux destinataires suivants :",
                    "Your message was delivered to the following recipients:",
                ),
                DsnAction::Relayed => (
                    "Votre message a été transmis aux destinataires suivants ; le serveur \
                     suivant ne fournit pas d'avis de remise :",
                    "Your message was relayed to the following recipients; the next server \
                     does not provide delivery notifications:",
                ),
                DsnAction::Expanded => (
                    "Votre message a été remis aux listes suivantes, qui le redistribuent :",
                    "Your message was delivered to the following lists, which redistribute it:",
                ),
            };
            let _ = write!(fr, "\n{intro_fr}\n\n");
            let _ = write!(en, "\n{intro_en}\n\n");
            for recipient in recipients {
                let address = sanitize_field(&recipient.final_recipient.address, true);
                let status = recipient.status;
                match recipient.will_retry_until {
                    Some(until) => {
                        let until = format_date(until);
                        let _ = writeln!(fr, "  {address} ({status}, essais jusqu'au {until})");
                        let _ = writeln!(en, "  {address} ({status}, retrying until {until})");
                    }
                    None => {
                        let _ = writeln!(fr, "  {address} ({status})");
                        let _ = writeln!(en, "  {address} ({status})");
                    }
                }
            }
        }
        fr.push_str("\nLe détail technique figure dans le rapport joint.\n");
        en.push_str("\nTechnical details are in the attached report.\n");
        format!("{fr}\n-- \n\n{en}")
    }
}

/// Écriture dans un tampon d'octets par `write!` (texte UTF-8).
struct Fields<'a>(&'a mut Vec<u8>);

impl std::fmt::Write for Fields<'_> {
    fn write_str(&mut self, text: &str) -> std::fmt::Result {
        self.0.extend_from_slice(text.as_bytes());
        Ok(())
    }
}

fn part_start(out: &mut Vec<u8>, boundary: &str) {
    out.extend_from_slice(b"\r\n--");
    out.extend_from_slice(boundary.as_bytes());
    out.extend_from_slice(b"\r\n");
}

/// `type; adresse` : `rfc822` tel quel ; `utf-8` en utf-8-addr-unitext (avis international)
/// ou utf-8-addr-xtext (ASCII seul, RFC 6533 §3). Valeur assainie.
fn address_value(address_type: &str, address: &str, international: bool) -> String {
    let address_type = sanitize_token(address_type);
    let address = sanitize_field(address, true);
    let address = if address_type == "utf-8" {
        if international {
            encode_utf8_addr_unitext(&address)
        } else {
            encode_utf8_addr_xtext(&address)
        }
    } else if address.is_ascii() {
        address
    } else {
        // Une adresse non ASCII ne s'écrit qu'en type `utf-8`.
        return format!(
            "utf-8; {}",
            if international {
                encode_utf8_addr_unitext(&address)
            } else {
                encode_utf8_addr_xtext(&address)
            }
        );
    };
    format!("{address_type}; {address}")
}

/// Mot ASCII (`atom` : lettres, chiffres, `-`), en minuscules ; `unknown` s'il est vide.
fn sanitize_token(value: &str) -> String {
    let token: String = value
        .chars()
        .filter(|ch| ch.is_ascii_alphanumeric() || *ch == '-')
        .take(64)
        .collect::<String>()
        .to_ascii_lowercase();
    if token.is_empty() {
        "unknown".to_owned()
    } else {
        token
    }
}

/// En-têtes du message, jusqu'à la ligne vide (exclue), [`MAX_RETURNED_BYTES`] au plus, coupés
/// à une fin de ligne.
fn header_block(message: &[u8]) -> &[u8] {
    let end = memchr::memmem::find(message, b"\r\n\r\n").map_or(message.len(), |end| end + 2);
    let headers = &message[..end];
    if headers.len() <= MAX_RETURNED_BYTES {
        return headers;
    }
    let limited = &headers[..MAX_RETURNED_BYTES];
    memchr::memmem::rfind(limited, b"\r\n").map_or(&[][..], |end| &limited[..end + 2])
}

fn is_hostname(value: &str) -> bool {
    !value.is_empty()
        && value.len() <= 255
        && value.split('.').all(|label| {
            !label.is_empty()
                && label.len() <= 63
                && label
                    .bytes()
                    .all(|b| b.is_ascii_alphanumeric() || b == b'-')
                && !label.starts_with('-')
                && !label.ends_with('-')
        })
}

fn is_message_id(value: &str) -> bool {
    !value.is_empty()
        && value.len() <= MAX_MESSAGE_ID_BYTES
        && value
            .bytes()
            .all(|b| b.is_ascii_graphic() && b != b'<' && b != b'>')
}
