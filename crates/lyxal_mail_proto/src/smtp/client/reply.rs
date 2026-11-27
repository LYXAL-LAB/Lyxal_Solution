// SPDX-License-Identifier: AGPL-3.0-only

//! Lecture des réponses d'un serveur distant (RFC 5321 §4.2, codes étendus RFC 3463 annoncés
//! par `ENHANCEDSTATUSCODES`, RFC 2034).
//!
//! Écrit pour Lyxal OS sur le modèle de Stalwart `smtp-proto` (`response/parser.rs`) et de Mox
//! (`smtpclient/client.go`, `read1`, `readecode`, `parseEcode` : code étendu lu seulement s'il
//! est annoncé et si sa classe est celle du code ; ligne `250` sans texte ni espace acceptée).
//! Différences voulues : une ligne ne se termine que par CRLF (un LF isolé ou un CR isolé est
//! une erreur de protocole, comme le serveur du lot 5) ; lignes et nombre de lignes bornés ; le
//! lecteur ne consomme **qu'une réponse à la fois** (réponses en `PIPELINING` lues dans l'ordre ;
//! après la réponse `220` à `STARTTLS`, tout octet déjà reçu est une injection).

use super::super::receiver::Ingested;
use super::super::response::{EnhancedStatus, Response, MAX_REPLY_LINE_BYTES};

/// Nombre maximal de lignes d'une réponse.
pub const MAX_REPLY_LINES: usize = 1_000;

/// Réponse illisible. Erreur de protocole : la connexion n'est plus synchronisée et doit être
/// fermée (le lecteur est remis à zéro). Aucune donnée du serveur n'y figure.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum ReplyError {
    /// Ligne plus longue que [`MAX_REPLY_LINE_BYTES`], CRLF compris.
    #[error("ligne de réponse trop longue")]
    LineTooLong,
    /// Plus de [`MAX_REPLY_LINES`] lignes.
    #[error("réponse de plus de {MAX_REPLY_LINES} lignes")]
    TooManyLines,
    /// CR non suivi de LF.
    #[error("CR isolé dans une réponse")]
    BareCr,
    /// LF non précédé de CR.
    #[error("LF isolé dans une réponse")]
    BareLf,
    /// Ligne qui ne commence pas par un code `2yz` à `5yz` (deuxième chiffre de 0 à 5).
    #[error("code de réponse invalide")]
    InvalidCode,
    /// Code suivi d'autre chose qu'une espace, un tiret ou la fin de ligne.
    #[error("séparateur de réponse invalide")]
    InvalidSeparator,
    /// Lignes d'une même réponse avec des codes différents (RFC 5321 §4.2.1).
    #[error("codes différents dans une réponse sur plusieurs lignes")]
    CodeMismatch,
}

/// Lit les réponses d'un serveur, une à la fois.
///
/// Mémoire bornée : une ligne de [`MAX_REPLY_LINE_BYTES`] octets et [`MAX_REPLY_LINES`] lignes
/// au plus. Les textes rendus sont assainis ([`Response`] : ASCII imprimable, tout autre
/// caractère devient `?`).
#[derive(Debug, Default)]
pub struct ReplyReader {
    line: Vec<u8>,
    code: Option<u16>,
    status: Option<EnhancedStatus>,
    lines: Vec<String>,
    enhanced: bool,
}

impl ReplyReader {
    /// Lecteur sans lecture des codes étendus (accueil, réponse à `EHLO`).
    pub fn new() -> Self {
        Self::default()
    }

    /// Lit (ou non) le code étendu en tête de chaque ligne : à activer quand le serveur annonce
    /// `ENHANCEDSTATUSCODES` (RFC 2034 §3), à désactiver après une nouvelle réponse à `EHLO`
    /// qui ne l'annonce plus.
    pub fn set_enhanced_status_codes(&mut self, enabled: bool) {
        self.enhanced = enabled;
    }

    /// Vrai si une réponse commencée (ligne ou lignes de continuation) attend sa fin. Après la
    /// réponse `220` à `STARTTLS`, le client vérifie qu'aucun octet ne reste (RFC 3207 §4.2).
    pub fn has_partial_reply(&self) -> bool {
        !self.line.is_empty() || !self.lines.is_empty()
    }

    /// Consomme `input` jusqu'à la fin de la première réponse complète au plus ; le reste de
    /// l'entrée appartient à la réponse suivante.
    pub fn ingest(&mut self, input: &[u8]) -> Ingested<Result<Response, ReplyError>> {
        let mut index = 0;
        while index < input.len() {
            let rest = &input[index..];
            let Some(lf) = memchr::memchr(b'\n', rest) else {
                if self.line.len() + rest.len() >= MAX_REPLY_LINE_BYTES {
                    return self.fail(input.len(), ReplyError::LineTooLong);
                }
                self.line.extend_from_slice(rest);
                return Ingested {
                    consumed: input.len(),
                    item: None,
                };
            };
            index += lf + 1;
            if self.line.len() + lf + 1 > MAX_REPLY_LINE_BYTES {
                return self.fail(index, ReplyError::LineTooLong);
            }
            self.line.extend_from_slice(&rest[..=lf]);
            let line = std::mem::take(&mut self.line);
            match self.line_read(&line) {
                Err(error) => return self.fail(index, error),
                Ok(false) => {}
                Ok(true) => {
                    let reply = self.finish();
                    return Ingested {
                        consumed: index,
                        item: Some(reply),
                    };
                }
            }
        }
        Ingested {
            consumed: index,
            item: None,
        }
    }

    /// Lit une ligne complète terminée par LF ; rend vrai pour la dernière ligne.
    fn line_read(&mut self, line: &[u8]) -> Result<bool, ReplyError> {
        let content = line
            .strip_suffix(b"\n")
            .and_then(|line| line.strip_suffix(b"\r"))
            .ok_or(ReplyError::BareLf)?;
        if memchr::memchr(b'\r', content).is_some() {
            return Err(ReplyError::BareCr);
        }
        let code = parse_code(content).ok_or(ReplyError::InvalidCode)?;
        if self.code.is_some_and(|previous| previous != code) {
            return Err(ReplyError::CodeMismatch);
        }
        let (last, text) = match content.get(3) {
            None => (true, &b""[..]),
            Some(b' ') => (true, &content[4..]),
            Some(b'-') => (false, &content[4..]),
            Some(_) => return Err(ReplyError::InvalidSeparator),
        };
        if self.lines.len() >= MAX_REPLY_LINES {
            return Err(ReplyError::TooManyLines);
        }
        let text = String::from_utf8_lossy(text);
        let text: &str = if self.enhanced {
            self.strip_status(code, &text)
        } else {
            &text
        };
        self.code = Some(code);
        self.lines.push(text.to_owned());
        Ok(last)
    }

    /// Retire le code étendu en tête du texte : lu sur la première ligne s'il a la classe du
    /// code, retiré des lignes suivantes s'il est le même.
    fn strip_status<'t>(&mut self, code: u16, text: &'t str) -> &'t str {
        let (token, rest) = match text.split_once(' ') {
            Some((token, rest)) => (token, rest),
            None => (text, ""),
        };
        let Some(status) = EnhancedStatus::parse(token) else {
            return text;
        };
        let matches = if self.lines.is_empty() {
            let same_class = u16::from(status.class()) == code / 100;
            if same_class {
                self.status = Some(status);
            }
            same_class
        } else {
            self.status == Some(status)
        };
        if matches {
            rest
        } else {
            text
        }
    }

    fn finish(&mut self) -> Result<Response, ReplyError> {
        let code = self.code.take().unwrap_or_default();
        let status = self.status.take();
        let lines = std::mem::take(&mut self.lines);
        Response::with_lines(code, status, lines).map_err(|_| ReplyError::InvalidCode)
    }

    fn fail(
        &mut self,
        consumed: usize,
        error: ReplyError,
    ) -> Ingested<Result<Response, ReplyError>> {
        self.line.clear();
        self.code = None;
        self.status = None;
        self.lines.clear();
        Ingested {
            consumed,
            item: Some(Err(error)),
        }
    }
}

/// Code `2yz` à `5yz`, deuxième chiffre de 0 à 5 (RFC 5321 §4.2.1), en tête de ligne.
fn parse_code(line: &[u8]) -> Option<u16> {
    let digits = line.get(..3)?;
    if !digits.iter().all(u8::is_ascii_digit)
        || !(b'2'..=b'5').contains(&digits[0])
        || digits[1] > b'5'
    {
        return None;
    }
    Some(
        digits
            .iter()
            .fold(0u16, |code, digit| code * 10 + u16::from(digit - b'0')),
    )
}
