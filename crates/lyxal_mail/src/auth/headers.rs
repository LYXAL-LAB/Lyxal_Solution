// SPDX-License-Identifier: AGPL-3.0-only

//! Découpage brut de l'en-tête d'un message (RFC 5322 §2.2) : champs (nom, valeur brute avec
//! ses repliements) et corps, sans aucune interprétation. Sert à DKIM (en-têtes de `h=`,
//! octets du corps), au compte des champs `From` et au retrait des `Authentication-Results`
//! falsifiés.

/// Nombre maximal de champs lus dans l'en-tête d'un message.
pub const MAX_HEADER_FIELDS: usize = 10_000;

/// Champ d'en-tête brut.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct HeaderField<'a> {
    /// Nom brut : octets avant le premier `:` (espaces de la syntaxe obsolète `obs-optional`
    /// compris, RFC 5322 §4.5.8 ; voir [`HeaderField::trimmed_name`]).
    pub name: &'a [u8],
    /// Valeur brute : octets après ce `:`, repliements compris, sans la fin de ligne finale.
    pub value: &'a [u8],
    /// Champ entier, fin de ligne finale comprise (pour le recopier ou le retirer).
    pub raw: &'a [u8],
}

impl HeaderField<'_> {
    /// Nom sans les espaces qui précèdent le `:`.
    pub fn trimmed_name(&self) -> &[u8] {
        let end = self
            .name
            .iter()
            .rposition(|byte| *byte != b' ' && *byte != b'\t')
            .map_or(0, |index| index + 1);
        self.name.get(..end).unwrap_or_default()
    }

    /// Vrai si le nom du champ est `name` (casse ASCII ignorée).
    pub fn is(&self, name: &str) -> bool {
        self.trimmed_name().eq_ignore_ascii_case(name.as_bytes())
    }
}

/// En-tête illisible (aucune donnée du message n'y figure).
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum HeaderError {
    /// Ligne de suite sans champ, ligne sans `:` ou nom de champ invalide.
    #[error("en-tête mal formé")]
    Malformed,
    /// Plus de [`MAX_HEADER_FIELDS`] champs.
    #[error("trop de champs d'en-tête")]
    TooManyFields,
}

/// Message découpé : champs dans l'ordre et corps.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct MessageHeaders<'a> {
    /// Champs, du premier au dernier.
    pub fields: Vec<HeaderField<'a>>,
    /// Corps : octets après la ligne vide qui termine l'en-tête (vide s'il n'y en a pas).
    pub body: &'a [u8],
}

impl<'a> MessageHeaders<'a> {
    /// Découpe un message. Fins de ligne CRLF (ou LF seul, toléré ici : la session SMTP les
    /// refuse en amont).
    pub fn parse(raw: &'a [u8]) -> Result<Self, HeaderError> {
        let mut fields: Vec<HeaderField<'a>> = Vec::new();
        let mut position = 0;
        let mut current: Option<(usize, usize)> = None; // (début du champ, position du `:`)
        while position < raw.len() {
            let rest = raw.get(position..).unwrap_or_default();
            let line_length = rest
                .iter()
                .position(|byte| *byte == b'\n')
                .map_or(rest.len(), |index| index + 1);
            let line = rest.get(..line_length).unwrap_or_default();
            let content = strip_line_end(line);
            if content.is_empty() {
                // Ligne vide : fin de l'en-tête.
                close(raw, &mut fields, current.take(), position)?;
                return Ok(Self {
                    fields,
                    body: raw.get(position + line_length..).unwrap_or_default(),
                });
            }
            let first = content.first().copied().unwrap_or_default();
            if first == b' ' || first == b'\t' {
                if current.is_none() {
                    return Err(HeaderError::Malformed);
                }
            } else {
                close(raw, &mut fields, current.take(), position)?;
                let colon = content
                    .iter()
                    .position(|byte| *byte == b':')
                    .ok_or(HeaderError::Malformed)?;
                let raw_name = content.get(..colon).unwrap_or_default();
                let name_end = raw_name
                    .iter()
                    .rposition(|byte| *byte != b' ' && *byte != b'\t')
                    .map_or(0, |index| index + 1);
                let name = raw_name.get(..name_end).unwrap_or_default();
                if name.is_empty() || !name.iter().all(|byte| (33..=126).contains(byte)) {
                    return Err(HeaderError::Malformed);
                }
                current = Some((position, position + colon));
            }
            position += line_length;
        }
        close(raw, &mut fields, current.take(), position)?;
        Ok(Self { fields, body: &[] })
    }

    /// Nombre de champs de ce nom.
    pub fn count(&self, name: &str) -> usize {
        self.fields.iter().filter(|field| field.is(name)).count()
    }
}

fn strip_line_end(line: &[u8]) -> &[u8] {
    let line = line.strip_suffix(b"\n").unwrap_or(line);
    line.strip_suffix(b"\r").unwrap_or(line)
}

fn close<'a>(
    raw: &'a [u8],
    fields: &mut Vec<HeaderField<'a>>,
    current: Option<(usize, usize)>,
    end: usize,
) -> Result<(), HeaderError> {
    let Some((start, colon)) = current else {
        return Ok(());
    };
    if fields.len() >= MAX_HEADER_FIELDS {
        return Err(HeaderError::TooManyFields);
    }
    let whole = raw.get(start..end).unwrap_or_default();
    fields.push(HeaderField {
        name: raw.get(start..colon).unwrap_or_default(),
        value: strip_line_end(raw.get(colon + 1..end).unwrap_or_default()),
        raw: whole,
    });
    Ok(())
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used)]
mod tests {
    use super::*;

    #[test]
    fn champs_et_corps() {
        let raw = b"From: a@example.com\r\nSubject: un\r\n deux\r\nX:\r\n\r\ncorps\r\n";
        let headers = MessageHeaders::parse(raw).unwrap();
        assert_eq!(headers.fields.len(), 3);
        assert_eq!(headers.fields[1].name, b"Subject");
        assert_eq!(headers.fields[1].value, b" un\r\n deux");
        assert_eq!(headers.fields[1].raw, b"Subject: un\r\n deux\r\n");
        assert_eq!(headers.fields[2].value, b"");
        assert_eq!(headers.body, b"corps\r\n");
        assert_eq!(headers.count("from"), 1);
        // Syntaxe obsolète : espaces avant le `:`.
        let headers = MessageHeaders::parse(b"SUBJECT \t: x\r\n\r\n").unwrap();
        assert_eq!(headers.fields[0].name, b"SUBJECT \t");
        assert!(headers.fields[0].is("subject"));
    }

    #[test]
    fn sans_corps() {
        let headers = MessageHeaders::parse(b"A: 1\r\nB: 2").unwrap();
        assert_eq!(headers.fields.len(), 2);
        assert_eq!(headers.fields[1].value, b" 2");
        assert!(headers.body.is_empty());
    }

    #[test]
    fn refus() {
        assert_eq!(
            MessageHeaders::parse(b" suite\r\n\r\n"),
            Err(HeaderError::Malformed)
        );
        assert_eq!(
            MessageHeaders::parse(b"sans deux points\r\n\r\n"),
            Err(HeaderError::Malformed)
        );
        assert_eq!(
            MessageHeaders::parse(b": vide\r\n\r\n"),
            Err(HeaderError::Malformed)
        );
    }
}
