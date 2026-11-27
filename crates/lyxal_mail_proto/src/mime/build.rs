// SPDX-License-Identifier: AGPL-3.0-only

//! Projection du résultat de `mail-parser` 1.0 en types Lyxal, sous les limites.
//!
//! `mail-parser` 1.0 range toutes les parties et tous les messages joints d'un message dans des
//! tables plates (aucune structure récursive à libérer) et borne lui-même la profondeur, le
//! nombre de parties et l'imbrication des messages joints encodés : une partie au-delà est
//! gardée comme feuille et marquée `LIMIT_REACHED`. Il est réglé ici un cran au-dessus des
//! [`MimeLimits`] pour que le dépassement soit vu par ce module, qui le rend en [`MimeError`].
//! La projection n'est pas récursive (pile explicite) : sa pile d'appel ne dépend pas de la
//! profondeur du message.

use mail_parser::{
    Address, AddressList, DateTime, HeaderForm, HeaderName, MessageParser, MessagePart, MessageRef,
    PartFlags, PartId, PartKind, Source, TextList,
};
use std::collections::HashSet;
use time::{Date, Month, OffsetDateTime, PrimitiveDateTime, Time, UtcOffset};

use super::{
    AddressEntry, BodyPart, EmbeddedMessage, Envelope, MailAddress, MimeError, MimeLimits,
    Parameter, ParsedMessage, PartBody, PartPosition, ThreadKeys,
};

/// Niveaux de messages joints encodés (base64, quoted-printable) décodés puis lus ; au-delà, la
/// partie reste une feuille marquée [`BodyPart::malformed`] (valeur par défaut de
/// `mail-parser`).
const MAX_ENCODED_NESTING: usize = 3;

/// Lecture d'un message (voir [`super::parse`]).
pub(super) fn parse(raw: &[u8], limits: &MimeLimits) -> Result<ParsedMessage, MimeError> {
    if raw.is_empty() {
        return Err(MimeError::Empty);
    }
    let max = u64::from(u32::MAX) - 1;
    let size = raw.len() as u64;
    if size > max {
        return Err(MimeError::TooLarge { size, max });
    }
    let parser = MessageParser::new()
        .unknown_headers(HeaderForm::Ignore)
        // Racine comprise, un conteneur de plus que la profondeur de `MimeLimits` : la partie
        // de trop est lue, puis refusée par `Context::part`.
        .max_depth(usize::from(limits.max_depth) + 2)
        .max_parts(usize::from(limits.max_parts) + 1)
        .max_encoded_nesting(MAX_ENCODED_NESTING);
    let message = parser.parse(raw).ok_or(MimeError::NoHeader)?;
    let root = message.root();
    if !has_field(root) {
        return Err(MimeError::NoHeader);
    }
    let mut context = Context {
        limits: *limits,
        total_parts: message.parts().len(),
        parts: 0,
        addresses: 0,
        has_attachment: false,
    };
    let envelope = context.envelope(root)?;
    let structure = context.tree(root.root_part())?;
    let thread = thread_keys(&envelope);
    let is_report = structure.media_type == "multipart" && structure.media_subtype == "report";
    Ok(ParsedMessage {
        envelope,
        structure,
        thread,
        base_subject: root.thread_name().and_then(normalize_subject),
        sent_at: root.date().as_ref().and_then(to_offset_date_time),
        has_attachment: context.has_attachment,
        is_report,
    })
}

/// Vrai si la partie racine porte au moins un champ d'en-tête (nom suivi de `:`) ; `mail-parser`
/// accepte aussi un message qui commence par une ligne vide ou un texte sans `:`.
fn has_field(message: MessageRef<'_>) -> bool {
    let source = message.source_bytes();
    message.headers().iter().any(|field| {
        (field.offset_start() as usize)
            .checked_sub(1)
            .and_then(|colon| source.get(colon))
            == Some(&b':')
    })
}

/// Partie en cours de lecture.
struct Node<'m> {
    id: PartId,
    depth: u8,
    /// Vrai dans un message joint (aucune pièce jointe comptée).
    embedded: bool,
    /// Champs lus ; `body` est fixé à la fermeture.
    part: BodyPart,
    work: Work<'m>,
}

/// Descendantes d'une partie en cours de lecture.
enum Work<'m> {
    Leaf,
    Multipart {
        digest: bool,
        children: std::vec::IntoIter<MessagePart<'m>>,
        built: Vec<BodyPart>,
    },
    Message {
        envelope: Box<Envelope>,
        nested: Option<MessageRef<'m>>,
        structure: Option<Box<BodyPart>>,
    },
}

/// Compteurs d'un message.
struct Context {
    limits: MimeLimits,
    /// Parties lues par `mail-parser`, messages joints compris.
    total_parts: usize,
    parts: u32,
    addresses: u32,
    has_attachment: bool,
}

impl Context {
    fn too_deep(&self) -> MimeError {
        MimeError::TooDeep {
            max: self.limits.max_depth,
        }
    }

    fn too_many_parts(&self) -> MimeError {
        MimeError::TooManyParts {
            max: self.limits.max_parts,
        }
    }

    /// Projette une partie et ses descendantes, sans récursion : la pile d'appel reste la même
    /// quelle que soit la profondeur ([`MimeLimits::max_depth`] jusqu'à 255).
    fn tree(&mut self, root: MessagePart<'_>) -> Result<BodyPart, MimeError> {
        let mut stack = vec![self.open(root, false, 0, false)?];
        loop {
            let Some(top) = stack.last_mut() else {
                return Err(MimeError::Inconsistent);
            };
            let next = match &mut top.work {
                Work::Leaf => None,
                Work::Multipart {
                    digest, children, ..
                } => children.next().map(|child| (child, *digest, top.embedded)),
                Work::Message { nested, .. } => nested
                    .take()
                    .map(|message| (message.root_part(), false, true)),
            };
            if let Some((child, digest, embedded)) = next {
                // Une partie ne contient que des parties lues après elle : sinon, cycle.
                if child.id() <= top.id {
                    return Err(MimeError::Inconsistent);
                }
                let depth = top.depth.checked_add(1).ok_or_else(|| self.too_deep())?;
                let node = self.open(child, digest, depth, embedded)?;
                stack.push(node);
                continue;
            }
            let node = stack.pop().ok_or(MimeError::Inconsistent)?;
            let done = self.close(node)?;
            match stack.last_mut().map(|parent| &mut parent.work) {
                None => return Ok(done),
                Some(Work::Multipart { built, .. }) => built.push(done),
                Some(Work::Message { structure, .. }) => *structure = Some(Box::new(done)),
                Some(Work::Leaf) => return Err(MimeError::Inconsistent),
            }
        }
    }

    /// Lit les champs d'une partie et prépare la lecture de ses descendantes.
    fn open<'m>(
        &mut self,
        part: MessagePart<'m>,
        digest_parent: bool,
        depth: u8,
        embedded: bool,
    ) -> Result<Node<'m>, MimeError> {
        if depth > self.limits.max_depth {
            return Err(self.too_deep());
        }
        self.parts += 1;
        if self.parts > u32::from(self.limits.max_parts) {
            return Err(self.too_many_parts());
        }
        if part.flags().contains(PartFlags::LIMIT_REACHED) {
            // Limite de `mail-parser` atteinte sans dépassement vu ici (filet de sécurité).
            return Err(if self.total_parts > usize::from(self.limits.max_parts) {
                self.too_many_parts()
            } else {
                self.too_deep()
            });
        }
        let mut malformed = part.has_problems();

        let (media_type, media_subtype, parameters) = match part.content_type() {
            Some(content_type) => {
                let media_type = content_type.ctype().to_ascii_lowercase();
                let (media_type, media_subtype) = match content_type.subtype() {
                    Some(subtype) => (media_type, subtype.to_ascii_lowercase()),
                    None => {
                        malformed = true;
                        match media_type.as_str() {
                            "multipart" => (media_type, "mixed".to_owned()),
                            "text" => (media_type, "plain".to_owned()),
                            _ => ("application".to_owned(), "octet-stream".to_owned()),
                        }
                    }
                };
                let parameters = parameter_list(content_type.attributes());
                (media_type, media_subtype, parameters)
            }
            None if digest_parent => ("message".to_owned(), "rfc822".to_owned(), Vec::new()),
            None => ("text".to_owned(), "plain".to_owned(), Vec::new()),
        };
        let (disposition, disposition_parameters) = match part.content_disposition() {
            Some(field) => (
                Some(field.ctype().to_ascii_lowercase()),
                parameter_list(field.attributes()),
            ),
            None => (None, Vec::new()),
        };

        // Positions : celles d'un message lu dans le message brut seulement ; un message joint
        // encodé est lu dans son contenu décodé, illisible par plage dans le fichier.
        let message = part.message();
        let source = message.source_bytes();
        let end = (part.offset_end() as usize).min(source.len());
        let body_start = (part.offset_body() as usize).min(end);
        let header_start = (part.offset_header() as usize).min(body_start);
        let position = (message.source() == Source::Raw).then_some(PartPosition {
            header_offset: header_start as u64,
            body_offset: body_start as u64,
            end_offset: end as u64,
        });
        let lines = (media_type == "text"
            || media_type == "message" && matches!(media_subtype.as_str(), "rfc822" | "global"))
        .then(|| count_lines(source.get(body_start..end).unwrap_or_default()));

        let work = match part.kind() {
            PartKind::Multipart => Work::Multipart {
                digest: media_type == "multipart" && media_subtype == "digest",
                children: part.children().collect::<Vec<_>>().into_iter(),
                built: Vec::new(),
            },
            PartKind::Message(nested) => Work::Message {
                envelope: Box::new(self.envelope(nested)?),
                nested: Some(nested),
                structure: None,
            },
            _ => Work::Leaf,
        };

        Ok(Node {
            id: part.id(),
            depth,
            embedded,
            work,
            part: BodyPart {
                media_type,
                media_subtype,
                parameters,
                disposition,
                disposition_parameters,
                file_name: part.attachment_name().map(str::to_owned),
                content_id: part.content_id().map(str::to_owned),
                description: part.content_description().map(str::to_owned),
                languages: part
                    .content_language()
                    .map(|list| list.iter().map(str::to_owned).collect())
                    .unwrap_or_default(),
                location: part.content_location().map(str::to_owned),
                transfer_encoding: part.content_transfer_encoding().and_then(first_word),
                position,
                size: (end - body_start) as u64,
                lines,
                is_attachment: false,
                malformed,
                body: PartBody::Single,
            },
        })
    }

    /// Termine une partie dont les descendantes sont lues.
    fn close(&mut self, node: Node<'_>) -> Result<BodyPart, MimeError> {
        let mut part = node.part;
        part.body = match node.work {
            Work::Leaf => PartBody::Single,
            Work::Multipart { built, .. } => PartBody::Multipart(built),
            Work::Message {
                envelope,
                structure,
                ..
            } => PartBody::Message(Box::new(EmbeddedMessage {
                envelope: *envelope,
                structure: *structure.ok_or(MimeError::Inconsistent)?,
            })),
        };
        if part.media_type == "multipart" && !matches!(part.body, PartBody::Multipart(_)) {
            // Frontière introuvable : `mail-parser` a lu la partie comme une feuille.
            part.malformed = true;
            part.body = PartBody::Multipart(Vec::new());
        }
        part.is_attachment = !node.embedded
            && match &part.body {
                // Un `multipart` n'est une pièce jointe que s'il est déclaré comme telle
                PartBody::Multipart(_) => part.disposition.as_deref() == Some("attachment"),
                PartBody::Message(_) => true,
                PartBody::Single => {
                    part.disposition.as_deref() == Some("attachment")
                        || part.file_name.is_some() && part.disposition.as_deref() != Some("inline")
                }
            };
        self.has_attachment |= part.is_attachment;
        Ok(part)
    }

    /// Enveloppe d'un message (champs de sa partie racine, dernier champ retenu).
    fn envelope(&mut self, message: MessageRef<'_>) -> Result<Envelope, MimeError> {
        let headers = message.headers();
        let date = headers
            .get(HeaderName::Date)
            .map(|field| unfold(field.raw_value()))
            .filter(|value| !value.is_empty());
        Ok(Envelope {
            date,
            subject: headers.subject().map(str::to_owned),
            from: self.addresses(headers.from())?,
            sender: self.addresses(headers.sender())?,
            reply_to: self.addresses(headers.reply_to())?,
            to: self.addresses(headers.to())?,
            cc: self.addresses(headers.cc())?,
            bcc: self.addresses(headers.bcc())?,
            message_id: identifiers(headers.message_id()).into_iter().next(),
            in_reply_to: identifiers(headers.in_reply_to().iter().flat_map(TextList::iter)),
            references: identifiers(headers.references().iter().flat_map(TextList::iter)),
        })
    }

    /// Liste d'adresses d'un champ, comptée dans la limite.
    fn addresses(&mut self, list: Option<AddressList<'_>>) -> Result<Vec<AddressEntry>, MimeError> {
        let mut entries = Vec::new();
        for item in list.iter().flat_map(AddressList::iter) {
            match item {
                Address::Mailbox(mailbox) => {
                    entries.push(AddressEntry::Mailbox(
                        self.address(mailbox.name(), mailbox.address())?,
                    ));
                }
                Address::Group(group) => {
                    let mut members = Vec::with_capacity(group.len());
                    for mailbox in group.mailboxes() {
                        members.push(self.address(mailbox.name(), mailbox.address())?);
                    }
                    match group.name() {
                        Some(name) => entries.push(AddressEntry::Group {
                            name: name.to_owned(),
                            members,
                        }),
                        None => entries.extend(members.into_iter().map(AddressEntry::Mailbox)),
                    }
                }
            }
        }
        Ok(entries)
    }

    fn address(
        &mut self,
        name: Option<&str>,
        address: Option<&str>,
    ) -> Result<MailAddress, MimeError> {
        self.addresses += 1;
        if self.addresses > u32::from(self.limits.max_addresses) {
            return Err(MimeError::TooManyAddresses {
                max: self.limits.max_addresses,
            });
        }
        Ok(MailAddress {
            name: name.map(str::to_owned),
            address: address.map(str::to_owned),
        })
    }
}

/// Premier mot d'une valeur, en minuscules (`Content-Transfer-Encoding`).
fn first_word(value: &str) -> Option<String> {
    let word = value
        .split(|c: char| c.is_ascii_whitespace() || matches!(c, ';' | '('))
        .find(|word| !word.is_empty())?;
    Some(word.to_ascii_lowercase())
}

/// Nombre de lignes d'un contenu (dernière ligne comptée même sans fin de ligne).
fn count_lines(content: &[u8]) -> u64 {
    let breaks = content.iter().filter(|&&byte| byte == b'\n').count() as u64;
    match content.last() {
        Some(b'\n') | None => breaks,
        Some(_) => breaks + 1,
    }
}

/// Valeur brute d'un champ, dépliée (fins de ligne retirées) et sans blancs autour.
fn unfold(value: &[u8]) -> String {
    let unfolded: Vec<u8> = value
        .iter()
        .copied()
        .filter(|byte| !matches!(byte, b'\r' | b'\n'))
        .collect();
    String::from_utf8_lossy(&unfolded).trim().to_owned()
}

fn parameter_list<'a>(attributes: impl Iterator<Item = (&'a str, &'a str)>) -> Vec<Parameter> {
    attributes
        .map(|(name, value)| Parameter {
            name: name.to_ascii_lowercase(),
            value: value.to_owned(),
        })
        .collect()
}

/// Identifiants `Message-ID`, `In-Reply-To` ou `References`, sans `<>` ni vides.
fn identifiers<'a>(values: impl IntoIterator<Item = &'a str>) -> Vec<String> {
    values
        .into_iter()
        .filter_map(|id| {
            let id = id.trim();
            let id = id.strip_prefix('<').unwrap_or(id);
            let id = id.strip_suffix('>').unwrap_or(id).trim();
            (!id.is_empty()).then(|| id.to_owned())
        })
        .collect()
}

/// Clés de fil : `In-Reply-To`, puis `References` du plus récent au plus ancien.
fn thread_keys(envelope: &Envelope) -> ThreadKeys {
    // Ensemble des identifiants déjà rangés : déduplication en temps linéaire, quel que soit le
    // nombre de `References` (contenu choisi par l'expéditeur)
    let mut seen: HashSet<&str> = HashSet::new();
    let mut ancestors: Vec<String> = Vec::new();
    for id in envelope
        .in_reply_to
        .iter()
        .chain(envelope.references.iter().rev())
    {
        if Some(id) != envelope.message_id.as_ref() && seen.insert(id.as_str()) {
            ancestors.push(id.clone());
        }
    }
    ThreadKeys {
        message_id: envelope.message_id.clone(),
        ancestors,
    }
}

/// Sujet de base : suites de blancs ramenées à une espace (RFC 5256 §2.1, étape 1).
fn normalize_subject(subject: &str) -> Option<String> {
    let normalized = subject.split_whitespace().collect::<Vec<_>>().join(" ");
    (!normalized.is_empty()).then_some(normalized)
}

/// Date de `mail-parser` en [`OffsetDateTime`] ; `None` si elle n'existe pas au calendrier.
pub(crate) fn to_offset_date_time(date: &DateTime) -> Option<OffsetDateTime> {
    let month = Month::try_from(date.month).ok()?;
    let day = Date::from_calendar_date(i32::from(date.year), month, date.day).ok()?;
    let time = Time::from_hms(date.hour, date.minute, date.second).ok()?;
    let sign: i8 = if date.tz_before_gmt { -1 } else { 1 };
    let hours = i8::try_from(date.tz_hour).ok()?.checked_mul(sign)?;
    let minutes = i8::try_from(date.tz_minute).ok()?.checked_mul(sign)?;
    let offset = UtcOffset::from_hms(hours, minutes, 0).ok()?;
    Some(PrimitiveDateTime::new(day, time).assume_offset(offset))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn compte_les_lignes() {
        assert_eq!(count_lines(b""), 0);
        assert_eq!(count_lines(b"a"), 1);
        assert_eq!(count_lines(b"a\r\n"), 1);
        assert_eq!(count_lines(b"a\r\nb"), 2);
    }

    #[test]
    fn normalise_les_identifiants() {
        assert_eq!(identifiers([" <a@b> ", "<>", "c@d"]), vec!["a@b", "c@d"]);
    }

    #[test]
    fn lit_le_premier_mot_d_un_encodage() {
        assert_eq!(first_word(" BASE64 (x)").as_deref(), Some("base64"));
        assert_eq!(first_word("  ").as_deref(), None);
    }

    #[test]
    fn ordonne_les_ancetres_du_plus_proche_au_plus_lointain() {
        let envelope = Envelope {
            message_id: Some("m".into()),
            in_reply_to: vec!["p".into()],
            references: vec!["r1".into(), "r2".into(), "p".into(), "m".into()],
            ..Envelope::default()
        };
        let keys = thread_keys(&envelope);
        assert_eq!(keys.ancestors, vec!["p", "r2", "r1"]);
    }

    /// Des dizaines de milliers de `References` distinctes se lisent en temps linéaire : la
    /// déduplication ne reparcourt pas les ancêtres déjà rangés.
    #[test]
    fn deduplique_de_tres_nombreux_ancetres_en_temps_lineaire() {
        let references: Vec<String> = (0..60_000).map(|i| format!("id{i}@exemple.test")).collect();
        let envelope = Envelope {
            references,
            ..Envelope::default()
        };
        let started = std::time::Instant::now();
        let keys = thread_keys(&envelope);
        assert_eq!(keys.ancestors.len(), 60_000);
        assert!(
            started.elapsed() < std::time::Duration::from_secs(1),
            "déduplication en {:?}",
            started.elapsed()
        );
    }

    #[test]
    fn refuse_une_date_hors_calendrier() {
        let date = DateTime {
            year: 2026,
            month: 2,
            day: 30,
            hour: 0,
            minute: 0,
            second: 0,
            tz_before_gmt: false,
            tz_hour: 0,
            tz_minute: 0,
        };
        assert!(to_offset_date_time(&date).is_none());
    }
}
