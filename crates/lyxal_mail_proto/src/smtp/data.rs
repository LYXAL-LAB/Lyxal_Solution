// SPDX-License-Identifier: AGPL-3.0-only

//! Lecture du contenu d'un message : `DATA` (RFC 5321 §4.1.1.4, §4.5.2) et morceaux `BDAT`
//! (RFC 3030).
//!
//! Écrit pour Lyxal OS sur le modèle de Stalwart `smtp-proto` (`request/receiver.rs`,
//! `DataReceiver`, `BdatReceiver`) et de Mox (`smtp/data.go`, `DataReader`).
//!
//! **Fins de ligne (décision S7, contrebande SMTP)** : la fin de `DATA` n'est reconnue que sur
//! `CRLF "." CRLF` ; un CR non suivi de LF ou un LF non précédé de CR n'est jamais une fin de
//! ligne pour ce repérage et est **signalé** ([`DataOutcome::line_ending_error`]). La lecture se
//! poursuit jusqu'à la vraie fin (le dialogue reste synchronisé) et la session refuse le message
//! (`500 5.5.2`). Variantes couvertes : `LF.LF`, `LF.CRLF`, `CRLF.LF`, `CR.CR`, `CRLF.CR`,
//! `CR.CRLF`, octet nul avant le point (essais `tests/smtp_data.rs`). Mox accepte un LF isolé
//! loin d'un point ; la décision S7 refuse toute fin isolée, `BDAT` compris (contrat de
//! `lyxal_crypto::dkim`).
//!
//! **Mémoire** : les octets au-delà de `max_message_bytes` sont lus et comptés sans être gardés
//! ([`DataOutcome::oversized`] : `552 5.3.4`). Les récepteurs ne consomment jamais au-delà de la
//! fin du message ou du morceau : le reste de l'entrée revient à [`super::CommandReceiver`].

use super::error::SmtpError;
use super::limits::SmtpLimits;
use super::receiver::Ingested;

/// Bilan d'un message lu.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct DataOutcome {
    /// Taille du message, bourrage de `DATA` retiré, octets non gardés compris.
    pub size: u64,
    /// Taille au-delà de `max_message_bytes` : les octets en trop n'ont pas été gardés.
    pub oversized: bool,
    /// Au moins un CR non suivi de LF.
    pub bare_cr: bool,
    /// Au moins un LF non précédé de CR.
    pub bare_lf: bool,
    /// Au moins un octet nul (interdit en `7BIT` et `8BITMIME`, RFC 6152 §3 ; `BINARYMIME`
    /// n'est pas annoncé).
    pub nul_byte: bool,
}

impl DataOutcome {
    /// Refus dû aux fins de ligne isolées (décision S7), s'il y a lieu.
    pub const fn line_ending_error(&self) -> Option<SmtpError> {
        if self.bare_cr {
            Some(SmtpError::BareCr)
        } else if self.bare_lf {
            Some(SmtpError::BareLf)
        } else {
            None
        }
    }
}

/// Compte, garde dans la limite, et relève les octets nuls.
#[derive(Debug)]
struct Sink {
    max: u64,
    outcome: DataOutcome,
}

impl Sink {
    fn new(max: u64) -> Self {
        Self {
            max,
            outcome: DataOutcome::default(),
        }
    }

    fn emit(&mut self, bytes: &[u8], out: &mut Vec<u8>) {
        if bytes.is_empty() {
            return;
        }
        let length = bytes.len() as u64;
        self.outcome.size = self.outcome.size.saturating_add(length);
        if !self.outcome.nul_byte && memchr::memchr(0, bytes).is_some() {
            self.outcome.nul_byte = true;
        }
        if self.outcome.size > self.max {
            self.outcome.oversized = true;
        }
        if !self.outcome.oversized {
            out.extend_from_slice(bytes);
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum DataState {
    /// Début de ligne (après CRLF, ou au début des données).
    LineStart,
    /// Milieu de ligne.
    Text,
    /// CR lu, LF attendu.
    Cr,
    /// Point lu en début de ligne.
    Dot,
    /// Point puis CR lus en début de ligne : LF termine les données.
    DotCr,
    /// Fin reconnue.
    Done,
}

/// Lit le contenu de `DATA`, après la réponse `354`.
#[derive(Debug)]
pub struct DataReceiver {
    state: DataState,
    sink: Sink,
}

impl DataReceiver {
    /// Récepteur d'un message.
    pub fn new(limits: &SmtpLimits) -> Self {
        Self {
            state: DataState::LineStart,
            sink: Sink::new(limits.max_message_bytes()),
        }
    }

    /// Consomme `input` jusqu'à la fin des données au plus ; ajoute le contenu, bourrage retiré,
    /// à `out` (l'appelant peut vider `out` entre deux appels). Rend le bilan à la fin
    /// `CRLF.CRLF`, qui n'est pas ajoutée (le CRLF qui la précède appartient au message).
    pub fn ingest(&mut self, input: &[u8], out: &mut Vec<u8>) -> Ingested<DataOutcome> {
        let mut index = 0;
        while index < input.len() {
            match self.state {
                DataState::Done => break,
                DataState::LineStart => match input[index] {
                    b'.' => {
                        self.state = DataState::Dot;
                        index += 1;
                    }
                    b'\r' => {
                        self.state = DataState::Cr;
                        index += 1;
                    }
                    _ => self.state = DataState::Text,
                },
                DataState::Text => {
                    let rest = &input[index..];
                    match memchr::memchr2(b'\r', b'\n', rest) {
                        None => {
                            self.sink.emit(rest, out);
                            index = input.len();
                        }
                        Some(position) => {
                            self.sink.emit(&rest[..position], out);
                            index += position + 1;
                            if rest[position] == b'\r' {
                                self.state = DataState::Cr;
                            } else {
                                self.sink.outcome.bare_lf = true;
                                self.sink.emit(b"\n", out);
                            }
                        }
                    }
                }
                DataState::Cr => {
                    if input[index] == b'\n' {
                        self.sink.emit(b"\r\n", out);
                        self.state = DataState::LineStart;
                        index += 1;
                    } else {
                        self.bare_cr(input[index], &mut index, out);
                    }
                }
                DataState::Dot => {
                    // Bourrage (RFC 5321 §4.5.2) : le point de tête est retiré.
                    if input[index] == b'\r' {
                        self.state = DataState::DotCr;
                        index += 1;
                    } else {
                        self.state = DataState::Text;
                    }
                }
                DataState::DotCr => {
                    if input[index] == b'\n' {
                        self.state = DataState::Done;
                        index += 1;
                        break;
                    }
                    self.bare_cr(input[index], &mut index, out);
                }
            }
        }
        Ingested {
            consumed: index,
            item: (self.state == DataState::Done).then_some(self.sink.outcome),
        }
    }

    /// CR suivi d'un autre octet que LF : le CR est isolé, gardé et signalé ; l'octet est relu
    /// (un second CR attend à son tour son LF).
    fn bare_cr(&mut self, byte: u8, index: &mut usize, out: &mut Vec<u8>) {
        self.sink.outcome.bare_cr = true;
        self.sink.emit(b"\r", out);
        if byte == b'\r' {
            self.state = DataState::Cr;
            *index += 1;
        } else {
            self.state = DataState::Text;
        }
    }
}

/// Appel de [`BdatReceiver::start_chunk`] hors de son ordre.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum BdatStateError {
    /// Le morceau précédent n'est pas entièrement lu.
    #[error("morceau BDAT précédent inachevé")]
    ChunkInProgress,
    /// Le dernier morceau (`LAST`) a déjà été reçu.
    #[error("message BDAT déjà terminé")]
    MessageFinished,
}

/// Lit les morceaux `BDAT` d'un message (RFC 3030 §2) : exactement la taille annoncée, sans
/// bourrage ; contrôle des fins de ligne sur tout le message, frontières de morceaux comprises.
#[derive(Debug)]
pub struct BdatReceiver {
    sink: Sink,
    remaining: u64,
    last: bool,
    finished: bool,
    pending_cr: bool,
}

impl BdatReceiver {
    /// Récepteur d'un message ; chaque morceau commence par [`BdatReceiver::start_chunk`].
    pub fn new(limits: &SmtpLimits) -> Self {
        Self {
            sink: Sink::new(limits.max_message_bytes()),
            remaining: 0,
            last: false,
            finished: false,
            pending_cr: false,
        }
    }

    /// Commence un morceau de `size` octets, après la commande `BDAT size [LAST]`.
    pub fn start_chunk(&mut self, size: u64, last: bool) -> Result<(), BdatStateError> {
        if self.finished || self.last {
            return Err(BdatStateError::MessageFinished);
        }
        if self.remaining > 0 {
            return Err(BdatStateError::ChunkInProgress);
        }
        self.remaining = size;
        self.last = last;
        Ok(())
    }

    /// Consomme `input` jusqu'à la fin du morceau au plus. Rend, à la fin du morceau, le bilan
    /// du message s'il s'agissait du dernier (`Some(Some(bilan))`), sinon `Some(None)` : la
    /// session répond `250` et lit la commande suivante.
    pub fn ingest(&mut self, input: &[u8], out: &mut Vec<u8>) -> Ingested<Option<DataOutcome>> {
        if self.finished {
            return Ingested {
                consumed: 0,
                item: Some(Some(self.sink.outcome)),
            };
        }
        let take = usize::try_from(self.remaining).map_or(input.len(), |rem| rem.min(input.len()));
        let chunk = &input[..take];
        self.check_line_endings(chunk);
        self.sink.emit(chunk, out);
        self.remaining -= take as u64;
        if self.remaining > 0 {
            return Ingested {
                consumed: take,
                item: None,
            };
        }
        let item = if self.last {
            self.finished = true;
            if self.pending_cr {
                self.sink.outcome.bare_cr = true;
                self.pending_cr = false;
            }
            Some(self.sink.outcome)
        } else {
            None
        };
        Ingested {
            consumed: take,
            item: Some(item),
        }
    }

    fn check_line_endings(&mut self, bytes: &[u8]) {
        let mut index = 0;
        while index < bytes.len() {
            if self.pending_cr {
                self.pending_cr = false;
                if bytes[index] == b'\n' {
                    index += 1;
                    continue;
                }
                self.sink.outcome.bare_cr = true;
            }
            match memchr::memchr2(b'\r', b'\n', &bytes[index..]) {
                None => break,
                Some(position) => {
                    let at = index + position;
                    if bytes[at] == b'\r' {
                        self.pending_cr = true;
                    } else {
                        self.sink.outcome.bare_lf = true;
                    }
                    index = at + 1;
                }
            }
        }
    }
}
