// SPDX-License-Identifier: AGPL-3.0-only

//! Découpage des lignes de commande (RFC 5321 §2.3.8, §4.5.3.1.4 ; RFC 2920).
//!
//! Écrit pour Lyxal OS sur le modèle de Stalwart `smtp-proto` (`request/receiver.rs`,
//! `RequestReceiver`), avec deux différences voulues : une ligne ne se termine que par CRLF (un
//! LF seul ou un CR isolé fait refuser la ligne, décision S7 ; Stalwart les accepte), et le
//! récepteur ne consomme **qu'une ligne à la fois** : les octets qui suivent restent à
//! l'appelant, qui décide de leur sort (morceau `BDAT`, refus après `STARTTLS` ou avant la
//! réponse `354`). Aucune lecture au-delà d'une frontière de protocole.

use super::command::{parse_command, Request};
use super::error::SmtpError;
use super::limits::SmtpLimits;

/// Résultat d'un appel à [`CommandReceiver::ingest`] ou à un récepteur de données.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Ingested<T> {
    /// Octets de l'entrée consommés ; le reste appartient à l'étape suivante du dialogue.
    pub consumed: usize,
    /// Élément complet, ou `None` si toute l'entrée a été consommée sans le terminer.
    pub item: Option<T>,
}

/// Accumule une ligne de commande, la contrôle et la lit.
///
/// Mémoire bornée : au plus `max_line_bytes` octets gardés ; une ligne plus longue est
/// consommée sans être gardée jusqu'à son LF, puis refusée ([`SmtpError::LineTooLong`]), de
/// sorte que la session reste synchronisée.
#[derive(Debug)]
pub struct CommandReceiver {
    buf: Vec<u8>,
    max_line: usize,
    overflow: bool,
}

impl CommandReceiver {
    /// Récepteur sous les limites données.
    pub fn new(limits: &SmtpLimits) -> Self {
        Self {
            buf: Vec::new(),
            max_line: limits.max_line_bytes(),
            overflow: false,
        }
    }

    /// Consomme `input` jusqu'à la fin de la première ligne au plus. Rend la commande lue (ou
    /// son refus) dès qu'une ligne est complète.
    pub fn ingest(&mut self, input: &[u8]) -> Ingested<Result<Request, SmtpError>> {
        let Some(lf) = memchr::memchr(b'\n', input) else {
            self.accumulate(input);
            return Ingested {
                consumed: input.len(),
                item: None,
            };
        };
        let consumed = lf + 1;
        let chunk = &input[..consumed];
        let result = if self.overflow || self.buf.len() + chunk.len() > self.max_line {
            Err(SmtpError::LineTooLong)
        } else if self.buf.is_empty() {
            check_and_parse(chunk)
        } else {
            self.buf.extend_from_slice(chunk);
            check_and_parse(&self.buf)
        };
        self.buf.clear();
        self.overflow = false;
        Ingested {
            consumed,
            item: Some(result),
        }
    }

    /// Vrai si une ligne commencée attend sa fin. Après `STARTTLS` ou `DATA` acceptés, la
    /// session vérifie qu'il n'y a ni ligne commencée ni octet restant
    /// ([`Request::forbids_pipelined_input`]).
    pub fn has_partial_line(&self) -> bool {
        !self.buf.is_empty() || self.overflow
    }

    /// Oublie la ligne commencée (après la mise à niveau TLS, RFC 3207 §4.2).
    pub fn reset(&mut self) {
        self.buf.clear();
        self.overflow = false;
    }

    fn accumulate(&mut self, input: &[u8]) {
        if self.overflow {
            return;
        }
        // La ligne n'aura pas la place de son LF : elle dépasse déjà la limite.
        if self.buf.len() + input.len() >= self.max_line {
            self.buf.clear();
            self.overflow = true;
            return;
        }
        self.buf.extend_from_slice(input);
    }
}

/// Contrôle une ligne complète terminée par LF, puis la lit.
fn check_and_parse(line: &[u8]) -> Result<Request, SmtpError> {
    let Some(without_lf) = line.strip_suffix(b"\n") else {
        return Err(SmtpError::BareLf);
    };
    let Some(content) = without_lf.strip_suffix(b"\r") else {
        return Err(SmtpError::BareLf);
    };
    if memchr::memchr(b'\r', content).is_some() {
        return Err(SmtpError::BareCr);
    }
    if memchr::memchr(0, content).is_some() {
        return Err(SmtpError::NulByte);
    }
    parse_command(content)
}
