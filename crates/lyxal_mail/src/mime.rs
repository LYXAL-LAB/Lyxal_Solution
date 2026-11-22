// SPDX-License-Identifier: AGPL-3.0-only

//! Projection d'un message lu par `lyxal_mail_proto` dans les champs de
//! `fn::mail_message_create` : enveloppe typée, structure MIME (objet libre), clés de fil.
//!
//! Un message reçu se garde même hors norme (plan du lot 4, §13) : les textes et les listes
//! plus longs que ce que le schéma de `mail_message` accepte sont raccourcis ici (texte coupé à
//! une limite de caractère, liste réduite à ses éléments les plus récents), au lieu de faire
//! refuser tout le message. Aucune règle d'acceptation n'est écrite ici : les entrées restent
//! contrôlées par `fn::mail_message_create`.

use lyxal_mail_proto::mime::{
    AddressEntry, BodyPart, Envelope, MailAddress, Parameter, ParsedMessage, PartBody,
};
use surrealdb::types::{Object, SurrealValue, Value};

use crate::models::{EnvelopeAddress, MailDatetime, MessageCreateParams, MessageEnvelope};

/// Longueur maximale d'un sujet (schéma de `mail_message`).
const MAX_SUBJECT: usize = 16_384;
/// Longueur maximale d'un identifiant de message, d'un nom ou d'une adresse.
const MAX_TEXT: usize = 2_048;
/// Identifiants de `In-Reply-To` gardés au plus.
const MAX_IN_REPLY_TO: usize = 100;
/// Identifiants de `References` gardés au plus (les plus récents).
const MAX_REFERENCES: usize = 1_000;
/// Adresses gardées au plus par champ.
const MAX_ADDRESSES: usize = 1_000;

/// Drapeaux d'un message déposé.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct DeliveryFlags {
    /// `\Seen`.
    pub seen: bool,
    /// `\Answered`.
    pub answered: bool,
    /// `\Flagged`.
    pub flagged: bool,
    /// `\Deleted`.
    pub deleted: bool,
    /// `\Draft`.
    pub draft: bool,
    /// Mots-clés.
    pub keywords: Vec<String>,
}

/// Texte coupé à `max` caractères au plus.
fn cut(text: &str, max: usize) -> String {
    match text.char_indices().nth(max) {
        Some((end, _)) => text[..end].to_string(),
        None => text.to_string(),
    }
}

fn cut_option(text: &Option<String>, max: usize) -> Option<String> {
    text.as_deref().map(|text| cut(text, max))
}

/// Liste d'identifiants : `max` éléments au plus, les premiers (`keep_last` faux) ou les
/// derniers.
fn ids(list: &[String], max: usize, keep_last: bool) -> Vec<String> {
    let start = if keep_last {
        list.len().saturating_sub(max)
    } else {
        0
    };
    list.iter()
        .skip(start)
        .take(max)
        .map(|id| cut(id, MAX_TEXT))
        .collect()
}

/// Date d'un message (secondes et nanosecondes depuis 1970), absente si elle sort des bornes.
pub(crate) fn datetime(seconds: i64, nanos: u32) -> Option<MailDatetime> {
    MailDatetime::from_timestamp(seconds, nanos)
}

fn address(address: &MailAddress, group: Option<&str>) -> EnvelopeAddress {
    EnvelopeAddress {
        name: cut_option(&address.name, MAX_TEXT),
        address: cut_option(&address.address, MAX_TEXT),
        group: group.map(|name| cut(name, MAX_TEXT)),
    }
}

/// Liste d'adresses à plat : un membre de groupe porte le nom de son groupe ; un groupe vide
/// n'a que son nom.
fn addresses(entries: &[AddressEntry]) -> Vec<EnvelopeAddress> {
    let mut flat = Vec::new();
    for entry in entries {
        match entry {
            AddressEntry::Mailbox(mailbox) => flat.push(address(mailbox, None)),
            AddressEntry::Group { name, members } if members.is_empty() => {
                flat.push(EnvelopeAddress {
                    name: None,
                    address: None,
                    group: Some(cut(name, MAX_TEXT)),
                });
            }
            AddressEntry::Group { name, members } => {
                flat.extend(members.iter().map(|member| address(member, Some(name))));
            }
        }
    }
    flat.truncate(MAX_ADDRESSES);
    flat
}

/// Enveloppe d'un message, datée par `date` (en-tête `Date` lu).
pub(crate) fn envelope(envelope: &Envelope, date: Option<MailDatetime>) -> MessageEnvelope {
    MessageEnvelope {
        date,
        subject: cut_option(&envelope.subject, MAX_SUBJECT),
        message_id: cut_option(&envelope.message_id, MAX_TEXT),
        in_reply_to: Some(ids(&envelope.in_reply_to, MAX_IN_REPLY_TO, false)),
        references: Some(ids(&envelope.references, MAX_REFERENCES, true)),
        from: Some(addresses(&envelope.from)),
        sender: Some(addresses(&envelope.sender)),
        reply_to: Some(addresses(&envelope.reply_to)),
        to: Some(addresses(&envelope.to)),
        cc: Some(addresses(&envelope.cc)),
        bcc: Some(addresses(&envelope.bcc)),
    }
}

fn insert_text(object: &mut Object, key: &str, value: &Option<String>) {
    if let Some(value) = value {
        object.insert(key, value.clone());
    }
}

fn parameters(list: &[Parameter]) -> Value {
    let items: Vec<Value> = list
        .iter()
        .map(|parameter| {
            let mut object = Object::new();
            object.insert("name", parameter.name.clone());
            object.insert("value", parameter.value.clone());
            Value::Object(object)
        })
        .collect();
    items.into_value()
}

fn count(value: u64) -> i64 {
    i64::try_from(value).unwrap_or(i64::MAX)
}

/// Enveloppe d'un message joint, rangée dans la structure : date brute de l'en-tête (texte).
fn embedded_envelope(envelope: &Envelope) -> Value {
    let mut object = Object::new();
    insert_text(&mut object, "date", &envelope.date);
    let typed = self::envelope(envelope, None);
    insert_text(&mut object, "subject", &typed.subject);
    insert_text(&mut object, "message_id", &typed.message_id);
    for (key, list) in [
        ("from", typed.from),
        ("sender", typed.sender),
        ("reply_to", typed.reply_to),
        ("to", typed.to),
        ("cc", typed.cc),
        ("bcc", typed.bcc),
    ] {
        object.insert(key, list.unwrap_or_default());
    }
    object.insert("in_reply_to", typed.in_reply_to.unwrap_or_default());
    object.insert("references", typed.references.unwrap_or_default());
    Value::Object(object)
}

/// Structure MIME d'une partie : type, paramètres, disposition, nom, positions dans le message
/// brut, tailles, lignes, parties ou message joint.
pub(crate) fn structure(part: &BodyPart) -> Value {
    let mut object = Object::new();
    object.insert("type", part.media_type.clone());
    object.insert("subtype", part.media_subtype.clone());
    object.insert("parameters", parameters(&part.parameters));
    insert_text(&mut object, "disposition", &part.disposition);
    if !part.disposition_parameters.is_empty() {
        object.insert(
            "disposition_parameters",
            parameters(&part.disposition_parameters),
        );
    }
    insert_text(&mut object, "file_name", &part.file_name);
    insert_text(&mut object, "content_id", &part.content_id);
    insert_text(&mut object, "description", &part.description);
    if !part.languages.is_empty() {
        object.insert("languages", part.languages.clone());
    }
    insert_text(&mut object, "location", &part.location);
    insert_text(&mut object, "transfer_encoding", &part.transfer_encoding);
    if let Some(position) = part.position {
        let mut offsets = Object::new();
        offsets.insert("header", count(position.header_offset));
        offsets.insert("body", count(position.body_offset));
        offsets.insert("end", count(position.end_offset));
        object.insert("position", Value::Object(offsets));
    }
    object.insert("size", count(part.size));
    if let Some(lines) = part.lines {
        object.insert("lines", count(lines));
    }
    object.insert("attachment", part.is_attachment);
    if part.malformed {
        object.insert("malformed", true);
    }
    match &part.body {
        PartBody::Single => {}
        PartBody::Multipart(parts) => {
            let children: Vec<Value> = parts.iter().map(structure).collect();
            object.insert("parts", children);
        }
        PartBody::Message(message) => {
            let mut embedded = Object::new();
            embedded.insert("envelope", embedded_envelope(&message.envelope));
            embedded.insert("structure", structure(&message.structure));
            object.insert("message", Value::Object(embedded));
        }
    }
    Value::Object(object)
}

/// Paramètres de `fn::mail_message_create` pour un message lu, son contenu stocké, son dossier,
/// sa date interne et ses drapeaux.
pub(crate) fn message_params(
    parsed: &ParsedMessage,
    content: String,
    mailbox: String,
    received_at: MailDatetime,
    flags: DeliveryFlags,
) -> MessageCreateParams {
    let sent_at = parsed
        .sent_at
        .and_then(|date| datetime(date.unix_timestamp(), date.nanosecond()));
    let envelope = envelope(&parsed.envelope, sent_at);
    MessageCreateParams {
        content,
        mailbox,
        received_at,
        sent_at,
        seen: flags.seen,
        answered: flags.answered,
        flagged: flags.flagged,
        deleted: flags.deleted,
        draft: flags.draft,
        keywords: flags.keywords,
        message_id: envelope.message_id.clone(),
        in_reply_to: envelope.in_reply_to.clone().unwrap_or_default(),
        references: envelope.references.clone().unwrap_or_default(),
        base_subject: cut_option(&parsed.base_subject, MAX_SUBJECT),
        is_report: parsed.is_report,
        envelope: Some(envelope),
        structure: Some(structure(&parsed.structure)),
        has_attachment: parsed.has_attachment,
    }
}

#[cfg(test)]
#[allow(clippy::expect_used, clippy::panic)]
mod tests {
    use super::*;
    use lyxal_mail_proto::mime::{parse, MimeLimits};

    const MESSAGE: &[u8] = b"From: Jean <jean@alpha.test>\r\n\
To: Equipe: marie@alpha.test, paul@alpha.test;, Vide:;\r\n\
Subject: Re: Devis\r\n\
Date: Tue, 3 Nov 2026 10:00:00 +0100\r\n\
Message-ID: <m2@alpha.test>\r\n\
In-Reply-To: <m1@alpha.test>\r\n\
MIME-Version: 1.0\r\n\
Content-Type: multipart/mixed; boundary=b\r\n\
\r\n\
--b\r\n\
Content-Type: text/plain\r\n\
\r\n\
Bonjour\r\n\
--b\r\n\
Content-Type: application/pdf; name=devis.pdf\r\n\
Content-Disposition: attachment; filename=devis.pdf\r\n\
\r\n\
JVBERi0=\r\n\
--b--\r\n";

    fn parsed() -> ParsedMessage {
        parse(MESSAGE, &MimeLimits::default()).expect("message lu")
    }

    #[test]
    fn groups_are_flattened_and_empty_groups_keep_their_name() {
        let envelope = envelope(&parsed().envelope, None);
        let to = envelope.to.expect("To");
        assert_eq!(to.len(), 3);
        assert_eq!(to[0].group.as_deref(), Some("Equipe"));
        assert_eq!(to[1].address.as_deref(), Some("paul@alpha.test"));
        assert_eq!(
            to[2],
            EnvelopeAddress {
                name: None,
                address: None,
                group: Some("Vide".to_string())
            }
        );
    }

    #[test]
    fn the_structure_keeps_types_positions_and_parts() {
        let message = parsed();
        let Value::Object(root) = structure(&message.structure) else {
            panic!("objet attendu");
        };
        assert_eq!(root.get("type"), Some(&Value::String("multipart".into())));
        let Some(Value::Array(parts)) = root.get("parts") else {
            panic!("parties attendues");
        };
        assert_eq!(parts.len(), 2);
        let Value::Object(pdf) = &parts[1] else {
            panic!("partie");
        };
        assert_eq!(pdf.get("attachment"), Some(&Value::Bool(true)));
        assert_eq!(
            pdf.get("file_name"),
            Some(&Value::String("devis.pdf".into()))
        );
        assert!(pdf.get("position").is_some());
    }

    #[test]
    fn message_params_carry_thread_keys_and_dates() {
        let params = message_params(
            &parsed(),
            "mail_content:c".to_string(),
            "mail_mailbox:b".to_string(),
            MailDatetime::now(),
            DeliveryFlags::default(),
        );
        assert_eq!(params.message_id.as_deref(), Some("m2@alpha.test"));
        assert_eq!(params.in_reply_to, vec!["m1@alpha.test".to_string()]);
        assert_eq!(params.base_subject.as_deref(), Some("Devis"));
        assert!(params.has_attachment);
        assert!(params.sent_at.is_some());
        assert_eq!(
            params.envelope.as_ref().and_then(|e| e.date),
            params.sent_at
        );
    }

    #[test]
    fn long_texts_and_lists_are_cut_to_the_schema() {
        assert_eq!(cut("éé", 1), "é");
        assert_eq!(cut("abc", 5), "abc");
        let list: Vec<String> = (0..1_500).map(|i| i.to_string()).collect();
        let kept = ids(&list, MAX_REFERENCES, true);
        assert_eq!(kept.len(), MAX_REFERENCES);
        assert_eq!(kept.last().map(String::as_str), Some("1499"));
        assert_eq!(ids(&list, 2, false), vec!["0", "1"]);
    }
}
