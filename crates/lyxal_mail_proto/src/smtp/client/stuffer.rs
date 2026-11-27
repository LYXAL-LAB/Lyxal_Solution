// SPDX-License-Identifier: AGPL-3.0-only

//! Bourrage du contenu de `DATA`, en flux (RFC 5321 §4.5.2) : un point en début de ligne est
//! doublé, la fin `CRLF "." CRLF` est ajoutée.
//!
//! Écrit pour Lyxal OS sur le modèle de Mox (`smtp/data.go`, `DataWrite`). Comme Mox, une fin
//! de ligne isolée (CR non suivi de LF, LF non précédé de CR) est **refusée**, jamais convertie :
//! le contenu en file est déjà contrôlé à son dépôt, ce refus est une seconde garde contre la
//! contrebande SMTP vers un serveur distant (un `LF.LF` transmis tel quel pourrait y terminer
//! les données). Différence : un contenu sans CRLF final est complété au lieu d'être refusé
//! (sans effet sur DKIM, RFC 6376 §3.4.3).

/// Contenu refusé.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum StuffError {
    /// CR non suivi de LF.
    #[error("CR isolé dans le contenu")]
    BareCr,
    /// LF non précédé de CR.
    #[error("LF isolé dans le contenu")]
    BareLf,
    /// Bourrage déjà terminé ([`DotStuffer::finish`]) ou interrompu par une erreur.
    #[error("bourrage terminé")]
    Finished,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum State {
    /// Début de ligne (après CRLF, ou au début du contenu).
    LineStart,
    /// Milieu de ligne.
    Text,
    /// CR écrit, LF attendu.
    Cr,
    /// Terminé ou interrompu.
    Finished,
}

/// Encodeur du contenu de `DATA`, à alimenter morceau par morceau.
#[derive(Debug)]
pub struct DotStuffer {
    state: State,
    written: u64,
}

impl Default for DotStuffer {
    fn default() -> Self {
        Self::new()
    }
}

impl DotStuffer {
    /// Encodeur d'un message.
    pub const fn new() -> Self {
        Self {
            state: State::LineStart,
            written: 0,
        }
    }

    /// Octets écrits dans `out` depuis le début, bourrage et fin compris.
    pub const fn written(&self) -> u64 {
        self.written
    }

    /// Ajoute `input`, bourré, à `out`. Une erreur termine l'encodeur : la transaction est à
    /// abandonner (connexion fermée, les données envoyées ne se terminent pas).
    pub fn encode(&mut self, input: &[u8], out: &mut Vec<u8>) -> Result<(), StuffError> {
        let start = out.len();
        let result = self.encode_inner(input, out);
        self.written += (out.len() - start) as u64;
        if result.is_err() {
            self.state = State::Finished;
        }
        result
    }

    fn encode_inner(&mut self, input: &[u8], out: &mut Vec<u8>) -> Result<(), StuffError> {
        let mut index = 0;
        while index < input.len() {
            match self.state {
                State::Finished => return Err(StuffError::Finished),
                State::LineStart => {
                    match input[index] {
                        b'.' => out.push(b'.'),
                        b'\n' => return Err(StuffError::BareLf),
                        _ => {}
                    }
                    self.state = State::Text;
                }
                State::Text => {
                    let rest = &input[index..];
                    match memchr::memchr2(b'\r', b'\n', rest) {
                        None => {
                            out.extend_from_slice(rest);
                            index = input.len();
                        }
                        Some(position) => {
                            if rest[position] == b'\n' {
                                out.extend_from_slice(&rest[..position]);
                                return Err(StuffError::BareLf);
                            }
                            out.extend_from_slice(&rest[..=position]);
                            index += position + 1;
                            self.state = State::Cr;
                        }
                    }
                }
                State::Cr => {
                    if input[index] != b'\n' {
                        return Err(StuffError::BareCr);
                    }
                    out.push(b'\n');
                    index += 1;
                    self.state = State::LineStart;
                }
            }
        }
        if self.state == State::Finished {
            return Err(StuffError::Finished);
        }
        Ok(())
    }

    /// Termine le contenu : `CRLF` si la dernière ligne n'en a pas, puis `.` `CRLF`.
    pub fn finish(&mut self, out: &mut Vec<u8>) -> Result<(), StuffError> {
        let end: &[u8] = match self.state {
            State::LineStart => b".\r\n",
            State::Text => b"\r\n.\r\n",
            State::Cr => {
                self.state = State::Finished;
                return Err(StuffError::BareCr);
            }
            State::Finished => return Err(StuffError::Finished),
        };
        out.extend_from_slice(end);
        self.written += end.len() as u64;
        self.state = State::Finished;
        Ok(())
    }
}
