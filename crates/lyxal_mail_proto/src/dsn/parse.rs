// SPDX-License-Identifier: AGPL-3.0-only

//! Lecture d'un avis reçu, sur le modèle de Mox (`dsn/parse.go`).
//!
//! La structure MIME vient de [`crate::mime::parse`] (lot 4) : la première partie
//! `message/delivery-status` ou `message/global-delivery-status` de l'arbre (hors messages
//! joints) est lue, qu'elle soit ou non sous un `multipart/report`. Tolérances, comme Mox ou
//! au-delà pour les avis réels : noms de champs sans égard à la casse, commentaires entre
//! parenthèses retirés des champs structurés, fins de ligne LF seules, groupe des champs du
//! message absent (le premier groupe porte déjà un destinataire), `Status` absent ou illisible
//! (déduit de l'action), adresse entre chevrons, groupe de destinataire illisible ignoré et
//! compté. Champs répétés : le premier est retenu.

use super::date::parse_date;
use super::encoding::{decode_base64, decode_quoted_printable, sanitize_chars, sanitize_field};
use super::{
    DeliveryReport, DsnAction, DsnAddress, DsnDiagnostic, DsnRecipient, MAX_DSN_RECIPIENTS,
    MAX_REPORT_BYTES,
};
use crate::mime::{BodyPart, ParsedMessage, PartBody};
use crate::smtp::xtext::decode_utf8_addr;
use crate::smtp::EnhancedStatus;

/// Avis illisible. Aucune donnée du message n'y figure.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum DsnParseError {
    /// Aucune partie `message/delivery-status` lisible : ce n'est pas un avis.
    #[error("aucun rapport delivery-status")]
    NotAReport,
    /// Partie `delivery-status` plus grande que [`MAX_REPORT_BYTES`].
    #[error("rapport delivery-status de plus de {MAX_REPORT_BYTES} octets")]
    TooLarge,
    /// Partie codée en Base64 invalide.
    #[error("rapport delivery-status mal codé")]
    InvalidEncoding,
    /// Plus de [`MAX_DSN_RECIPIENTS`] groupes de destinataire.
    #[error("rapport de plus de {MAX_DSN_RECIPIENTS} destinataires")]
    TooManyRecipients,
    /// Aucun destinataire lisible.
    #[error("rapport sans destinataire lisible")]
    NoRecipient,
}

/// Lit le rapport d'un avis reçu : `raw` est le message brut, `message` sa lecture MIME.
pub fn parse_dsn(raw: &[u8], message: &ParsedMessage) -> Result<DeliveryReport, DsnParseError> {
    let part = find_report(&message.structure).ok_or(DsnParseError::NotAReport)?;
    let position = part.position.ok_or(DsnParseError::NotAReport)?;
    let start = usize::try_from(position.body_offset).map_err(|_| DsnParseError::NotAReport)?;
    let end = usize::try_from(position.end_offset).map_err(|_| DsnParseError::NotAReport)?;
    let body = raw.get(start..end).ok_or(DsnParseError::NotAReport)?;
    if body.len() > MAX_REPORT_BYTES {
        return Err(DsnParseError::TooLarge);
    }
    let decoded = match part.transfer_encoding.as_deref() {
        Some("base64") => decode_base64(body).ok_or(DsnParseError::InvalidEncoding)?,
        Some("quoted-printable") => decode_quoted_printable(body),
        _ => body.to_vec(),
    };
    let international = part.media_subtype == "global-delivery-status";
    read_report(&String::from_utf8_lossy(&decoded), international)
}

/// Première partie `delivery-status` de l'arbre, en profondeur d'abord, hors messages joints.
fn find_report(root: &BodyPart) -> Option<&BodyPart> {
    let mut stack = vec![root];
    while let Some(part) = stack.pop() {
        if part.media_type == "message"
            && matches!(
                part.media_subtype.as_str(),
                "delivery-status" | "global-delivery-status"
            )
        {
            return Some(part);
        }
        if let PartBody::Multipart(children) = &part.body {
            stack.extend(children.iter().rev());
        }
    }
    None
}

/// Groupe de champs : noms en minuscules et valeurs dépliées, dans l'ordre.
type Group = Vec<(String, String)>;

fn read_report(text: &str, international: bool) -> Result<DeliveryReport, DsnParseError> {
    let mut groups = groups(text)?.into_iter();
    let mut report = DeliveryReport {
        international,
        reporting_mta: None,
        original_envelope_id: None,
        arrival_date: None,
        recipients: Vec::new(),
        ignored_recipients: 0,
    };
    let mut pending = None;
    if let Some(first) = groups.next() {
        let is_recipient = !has(&first, "reporting-mta")
            && (has(&first, "final-recipient") || has(&first, "action"));
        if is_recipient {
            pending = Some(first);
        } else {
            report.reporting_mta = field(&first, "reporting-mta").and_then(mta_name);
            // Seule l'espace qui suit le `:` est retirée : l'identifiant est gardé à l'octet près.
            report.original_envelope_id = field(&first, "original-envelope-id")
                .map(|value| {
                    sanitize_chars(value.strip_prefix(' ').unwrap_or(value), international)
                })
                .filter(|value| !value.is_empty());
            report.arrival_date = field(&first, "arrival-date").and_then(date);
        }
    }
    for group in pending.into_iter().chain(groups) {
        match recipient(&group, international) {
            Some(recipient) => report.recipients.push(recipient),
            None => report.ignored_recipients += 1,
        }
    }
    if report.recipients.is_empty() {
        return Err(DsnParseError::NoRecipient);
    }
    Ok(report)
}

/// Découpe le rapport en groupes séparés par des lignes vides ; déplie les champs
/// (RFC 5322 §2.2.3). Une ligne sans `:` hors d'un repli est ignorée.
fn groups(text: &str) -> Result<Vec<Group>, DsnParseError> {
    let mut groups: Vec<Group> = Vec::new();
    let mut current: Group = Vec::new();
    for line in text.split('\n') {
        let line = line.strip_suffix('\r').unwrap_or(line);
        if line.trim().is_empty() {
            if !current.is_empty() {
                // Groupe des champs du message, puis au plus `MAX_DSN_RECIPIENTS` destinataires.
                if groups.len() > MAX_DSN_RECIPIENTS {
                    return Err(DsnParseError::TooManyRecipients);
                }
                groups.push(std::mem::take(&mut current));
            }
            continue;
        }
        if line.starts_with([' ', '\t']) {
            if let Some((_, value)) = current.last_mut() {
                if value.len() < MAX_FIELD_READ {
                    value.push_str(line);
                }
            }
            continue;
        }
        if let Some((name, value)) = line.split_once(':') {
            let name = name.trim().to_ascii_lowercase();
            if !name.is_empty() {
                current.push((name, value.to_owned()));
            }
        }
    }
    if !current.is_empty() {
        if groups.len() > MAX_DSN_RECIPIENTS {
            return Err(DsnParseError::TooManyRecipients);
        }
        groups.push(current);
    }
    Ok(groups)
}

/// Longueur gardée d'une valeur pendant le dépliage (bornée ensuite par l'assainissement).
const MAX_FIELD_READ: usize = 2 * super::MAX_FIELD_BYTES;

fn has(group: &Group, name: &str) -> bool {
    group.iter().any(|(field, _)| field == name)
}

fn field<'g>(group: &'g Group, name: &str) -> Option<&'g str> {
    group
        .iter()
        .find(|(field, _)| field == name)
        .map(|(_, value)| value.as_str())
}

fn recipient(group: &Group, international: bool) -> Option<DsnRecipient> {
    let final_recipient =
        field(group, "final-recipient").and_then(|v| address(v, international))?;
    let action = field(group, "action")
        .map(remove_comments)
        .and_then(|value| DsnAction::from_name(value.trim()))?;
    let status = field(group, "status")
        .map(remove_comments)
        .and_then(|value| {
            value
                .split_whitespace()
                .next()
                .and_then(EnhancedStatus::parse)
        })
        .unwrap_or_else(|| action.default_status());
    Some(DsnRecipient {
        original_recipient: field(group, "original-recipient")
            .and_then(|value| address(value, international)),
        final_recipient,
        action,
        status,
        remote_mta: field(group, "remote-mta").and_then(mta_name),
        diagnostic: field(group, "diagnostic-code")
            .and_then(|value| diagnostic(value, international)),
        last_attempt_date: field(group, "last-attempt-date").and_then(date),
        will_retry_until: field(group, "will-retry-until").and_then(date),
    })
}

/// `address-type ";" generic-address` ; chevrons tolérés ; `utf-8` décodé (RFC 6533).
fn address(value: &str, international: bool) -> Option<DsnAddress> {
    let value = remove_comments(value);
    let (address_type, address) = value.split_once(';')?;
    let address_type = address_type.trim().to_ascii_lowercase();
    let address = address.trim();
    let address = address
        .strip_prefix('<')
        .and_then(|inner| inner.strip_suffix('>'))
        .unwrap_or(address);
    let address = if address_type == "utf-8" {
        decode_utf8_addr(address)?
    } else {
        address.to_owned()
    };
    let address = sanitize_field(&address, international || address_type == "utf-8");
    let type_ok = !address_type.is_empty()
        && address_type
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || b == b'-');
    (type_ok && !address.is_empty() && !address.contains(' ')).then_some(DsnAddress {
        address_type,
        address,
    })
}

/// `mta-name-type ";" mta-name` ; un nom sans type est gardé tel quel.
fn mta_name(value: &str) -> Option<String> {
    let value = remove_comments(value);
    let name = value
        .split_once(';')
        .map_or(value.as_str(), |(_, name)| name);
    let name = sanitize_field(name, false);
    (!name.is_empty()).then_some(name)
}

/// `diagnostic-type ";" *text` (texte gardé tel quel, parenthèses comprises).
fn diagnostic(value: &str, international: bool) -> Option<DsnDiagnostic> {
    let (kind, text) = value.split_once(';')?;
    let kind = kind.trim().to_ascii_lowercase();
    if kind.is_empty() || !kind.bytes().all(|b| b.is_ascii_alphanumeric() || b == b'-') {
        return None;
    }
    Some(DsnDiagnostic {
        diagnostic_type: kind,
        text: sanitize_field(text, international),
    })
}

fn date(value: &str) -> Option<time::OffsetDateTime> {
    parse_date(&remove_comments(value))
}

/// Retire les commentaires entre parenthèses (imbriqués compris), comme Mox. Une parenthèse
/// dans une chaîne entre guillemets (`"a(b)"@example.org`) ou échappée par `\` n'ouvre ni ne
/// ferme un commentaire (RFC 5322 §3.2.2 et §3.2.4).
fn remove_comments(value: &str) -> String {
    let mut depth = 0usize;
    let mut quoted = false;
    let mut escaped = false;
    let mut out = String::with_capacity(value.len());
    for ch in value.chars() {
        if escaped {
            escaped = false;
            if depth == 0 {
                out.push(ch);
            }
            continue;
        }
        if ch == '\\' {
            escaped = true;
            if depth == 0 {
                out.push(ch);
            }
            continue;
        }
        if quoted {
            out.push(ch);
            quoted = ch != '"';
            continue;
        }
        match ch {
            '"' if depth == 0 => {
                quoted = true;
                out.push(ch);
            }
            '(' => depth += 1,
            ')' if depth > 0 => depth -= 1,
            _ if depth == 0 => out.push(ch),
            _ => {}
        }
    }
    out
}
