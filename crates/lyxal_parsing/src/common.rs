//! Types communs aux trois lecteurs : positions, rejets, erreurs d'arrêt, limites, encodages,
//! et adaptateurs de lecture (décodage vers UTF-8, budget mémoire par enregistrement, lignes).

use std::fmt;
use std::io::{self, BufRead, Read};
use std::sync::atomic::{AtomicU64, AtomicUsize, Ordering};
use std::sync::Arc;

/// Position d'un enregistrement dans la source.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Position {
    /// Numéro de l'enregistrement, à partir de 1 (en-tête CSV exclu, rejets comptés).
    pub record: u64,
    /// Ligne de début dans le fichier (à partir de 1), quand le format la fournit.
    pub line: Option<u64>,
}

impl fmt::Display for Position {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self.line {
            Some(line) => write!(f, "enregistrement {}, ligne {line}", self.record),
            None => write!(f, "enregistrement {}", self.record),
        }
    }
}

/// Cause du rejet d'un enregistrement.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RejectionKind {
    /// Ligne CSV dont le nombre de champs diffère de l'en-tête.
    CsvFieldCount,
    /// Élément JSON qui n'est pas un objet.
    JsonNotObject,
    /// Élément JSON ou ligne NDJSON mal formé.
    JsonSyntax,
    /// Entité XML inconnue (seules les entités prédéfinies et numériques sont décodées).
    XmlEntity,
    /// Imbrication plus profonde que [`Limits::max_depth`].
    TooDeep,
    /// Enregistrement plus grand que [`Limits::max_record_bytes`].
    RecordTooLarge,
    /// Plus de champs que [`Limits::max_fields`].
    TooManyFields,
    /// Texte non décodable dans l'encodage de la source.
    InvalidText,
}

impl RejectionKind {
    /// Code stable du rejet (`PARSING_*`), repris en détail par le module consommateur.
    pub fn code(&self) -> &'static str {
        match self {
            Self::CsvFieldCount => "PARSING_CSV_FIELD_COUNT",
            Self::JsonNotObject => "PARSING_JSON_NOT_OBJECT",
            Self::JsonSyntax => "PARSING_JSON_SYNTAX",
            Self::XmlEntity => "PARSING_XML_ENTITY",
            Self::TooDeep => "PARSING_TOO_DEEP",
            Self::RecordTooLarge => "PARSING_RECORD_TOO_LARGE",
            Self::TooManyFields => "PARSING_TOO_MANY_FIELDS",
            Self::InvalidText => "PARSING_INVALID_TEXT",
        }
    }
}

/// Rejet d'un enregistrement : il est écarté, la lecture continue avec le suivant.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Rejection {
    /// Position de l'enregistrement rejeté.
    pub position: Position,
    /// Cause du rejet.
    pub kind: RejectionKind,
    /// Diagnostic lisible, sans le contenu de l'enregistrement.
    pub detail: String,
}

impl fmt::Display for Rejection {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{} ({}) : {}",
            self.kind.code(),
            self.position,
            self.detail
        )
    }
}

impl std::error::Error for Rejection {}

/// Erreur qui arrête la lecture : la suite de la source n'est plus fiable.
#[derive(Debug, thiserror::Error)]
pub enum ParseError {
    /// Lecture de la source impossible.
    #[error("PARSING_IO : lecture de la source impossible : {0}")]
    Io(#[source] io::Error),
    /// Texte non décodable alors que l'enregistrement concerné ne peut pas être isolé.
    #[error("PARSING_ENCODING ({}) : {detail}", line_label(*.line))]
    Encoding {
        /// Ligne approximative de l'erreur.
        line: Option<u64>,
        /// Diagnostic.
        detail: String,
    },
    /// Structure du document invalide (XML mal formé, tableau JSON cassé).
    #[error("PARSING_SYNTAX ({}) : {detail}", line_label(*.line))]
    Syntax {
        /// Ligne de l'erreur.
        line: Option<u64>,
        /// Diagnostic.
        detail: String,
    },
    /// En-tête CSV invalide (absent, colonne vide ou en double).
    #[error("PARSING_HEADER_INVALID : {detail}")]
    Header {
        /// Diagnostic.
        detail: String,
    },
    /// Limite de taille dépassée là où l'enregistrement ne peut pas être sauté.
    #[error("PARSING_LIMIT ({}) : {detail}", line_label(*.line))]
    Limit {
        /// Ligne approximative.
        line: Option<u64>,
        /// Diagnostic.
        detail: String,
    },
}

fn line_label(line: Option<u64>) -> String {
    match line {
        Some(line) => format!("ligne {line}"),
        None => "position inconnue".to_string(),
    }
}

impl ParseError {
    /// Code stable de l'erreur (`PARSING_*`).
    pub fn code(&self) -> &'static str {
        match self {
            Self::Io(_) => "PARSING_IO",
            Self::Encoding { .. } => "PARSING_ENCODING",
            Self::Syntax { .. } => "PARSING_SYNTAX",
            Self::Header { .. } => "PARSING_HEADER_INVALID",
            Self::Limit { .. } => "PARSING_LIMIT",
        }
    }
}

/// Échec rendu par un lecteur à la place d'un enregistrement.
#[derive(Debug, thiserror::Error)]
pub enum ReadFailure {
    /// L'enregistrement est écarté ; l'élément suivant de l'itérateur est lu normalement.
    #[error(transparent)]
    Rejected(Rejection),
    /// La lecture s'arrête : c'est le dernier élément rendu par l'itérateur.
    #[error(transparent)]
    Fatal(ParseError),
}

impl ReadFailure {
    /// Code stable de l'échec (`PARSING_*`).
    pub fn code(&self) -> &'static str {
        match self {
            Self::Rejected(rejection) => rejection.kind.code(),
            Self::Fatal(error) => error.code(),
        }
    }
}

/// Encodage de la source, toujours déclaré par l'appelant (jamais deviné).
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub enum SourceEncoding {
    /// UTF-8, marque d'ordre des octets (BOM) acceptée et retirée.
    #[default]
    Utf8,
    /// Windows-1252 (exports d'Excel en France).
    Windows1252,
    /// ISO-8859-1 (Latin-1) strict.
    Iso8859_1,
}

/// Limites appliquées à chaque enregistrement.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Limits {
    /// Taille maximale d'un enregistrement, en octets décodés (1 Mio par défaut). La mémoire
    /// utilisée par enregistrement reste bornée par cette taille et un tampon de lecture.
    pub max_record_bytes: usize,
    /// Nombre maximal de champs d'un enregistrement (10 000 par défaut).
    pub max_fields: usize,
    /// Profondeur maximale d'imbrication JSON ou XML dans un enregistrement (64 par défaut).
    pub max_depth: usize,
}

impl Default for Limits {
    fn default() -> Self {
        Self {
            max_record_bytes: 1024 * 1024,
            max_fields: 10_000,
            max_depth: 64,
        }
    }
}

/// Taille des tampons de lecture internes (marge au-delà de `max_record_bytes`).
pub(crate) const READ_BUFFER: usize = 64 * 1024;

// =============================================================================
// Décodage vers UTF-8
// =============================================================================

enum Mode {
    /// UTF-8 transmis tel quel (validé par chaque lecteur), BOM retiré.
    Utf8 {
        bom_checked: bool,
    },
    Windows1252(encoding_rs::Decoder),
    Latin1,
}

/// Source décodée en UTF-8, en flux.
pub(crate) struct Decoded<R> {
    inner: R,
    mode: Mode,
    input: Box<[u8]>,
    in_start: usize,
    in_end: usize,
    input_done: bool,
    output: Vec<u8>,
    out_pos: usize,
    finished: bool,
}

impl<R: Read> Decoded<R> {
    pub(crate) fn new(inner: R, encoding: SourceEncoding) -> Self {
        let mode = match encoding {
            SourceEncoding::Utf8 => Mode::Utf8 { bom_checked: false },
            SourceEncoding::Windows1252 => {
                Mode::Windows1252(encoding_rs::WINDOWS_1252.new_decoder_without_bom_handling())
            }
            SourceEncoding::Iso8859_1 => Mode::Latin1,
        };
        Self {
            inner,
            mode,
            input: vec![0; 16 * 1024].into_boxed_slice(),
            in_start: 0,
            in_end: 0,
            input_done: false,
            output: Vec::new(),
            out_pos: 0,
            finished: false,
        }
    }

    /// Lit au moins `wanted` octets d'entrée en attente (moins en fin de source).
    fn fill_input(&mut self, wanted: usize) -> io::Result<()> {
        if self.in_start > 0 {
            self.input.copy_within(self.in_start..self.in_end, 0);
            self.in_end -= self.in_start;
            self.in_start = 0;
        }
        while !self.input_done && self.in_end < wanted {
            let n = self.inner.read(&mut self.input[self.in_end..])?;
            if n == 0 {
                self.input_done = true;
            }
            self.in_end += n;
        }
        Ok(())
    }

    /// Produit le prochain morceau de texte décodé dans `output`.
    fn decode_next(&mut self) -> io::Result<()> {
        self.output.clear();
        self.out_pos = 0;
        if self.in_start == self.in_end {
            self.fill_input(1)?;
        }
        let pending = &self.input[self.in_start..self.in_end];
        match &mut self.mode {
            Mode::Utf8 { bom_checked } => {
                if !*bom_checked {
                    *bom_checked = true;
                    // Le BOM peut arriver en plusieurs lectures : on attend ses trois octets
                    let bom = [0xEF, 0xBB, 0xBF];
                    self.fill_input(bom.len())?;
                    let pending = &self.input[self.in_start..self.in_end];
                    if pending.starts_with(&bom) {
                        self.in_start += bom.len();
                    }
                }
                let pending = &self.input[self.in_start..self.in_end];
                self.output.extend_from_slice(pending);
                self.in_start = self.in_end;
                if pending.is_empty() && self.input_done {
                    self.finished = true;
                }
            }
            Mode::Latin1 => {
                for &byte in pending {
                    if byte < 0x80 {
                        self.output.push(byte);
                    } else {
                        self.output.push(0xC0 | (byte >> 6));
                        self.output.push(0x80 | (byte & 0x3F));
                    }
                }
                if pending.is_empty() && self.input_done {
                    self.finished = true;
                }
                self.in_start = self.in_end;
            }
            Mode::Windows1252(decoder) => {
                let last = self.input_done;
                let capacity = decoder
                    .max_utf8_buffer_length(pending.len())
                    .unwrap_or(pending.len() * 3 + 16);
                self.output.resize(capacity, 0);
                let (result, read, written) =
                    decoder.decode_to_utf8_without_replacement(pending, &mut self.output, last);
                self.output.truncate(written);
                self.in_start += read;
                match result {
                    encoding_rs::DecoderResult::InputEmpty => {
                        if last && self.in_start == self.in_end {
                            self.finished = true;
                        }
                    }
                    encoding_rs::DecoderResult::OutputFull => {}
                    encoding_rs::DecoderResult::Malformed(_, _) => {
                        return Err(io::Error::new(
                            io::ErrorKind::InvalidData,
                            "octet non décodable en Windows-1252",
                        ));
                    }
                }
            }
        }
        Ok(())
    }
}

impl<R: Read> Read for Decoded<R> {
    fn read(&mut self, buf: &mut [u8]) -> io::Result<usize> {
        loop {
            if self.out_pos < self.output.len() {
                let n = buf.len().min(self.output.len() - self.out_pos);
                buf[..n].copy_from_slice(&self.output[self.out_pos..self.out_pos + n]);
                self.out_pos += n;
                return Ok(n);
            }
            if self.finished || buf.is_empty() {
                return Ok(0);
            }
            self.decode_next()?;
        }
    }
}

// =============================================================================
// Budget mémoire par enregistrement
// =============================================================================

/// Dépassement du budget d'un enregistrement, transporté dans une `io::Error`.
#[derive(Debug)]
pub(crate) struct BudgetExceeded;

impl fmt::Display for BudgetExceeded {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("taille maximale d'un enregistrement dépassée")
    }
}

impl std::error::Error for BudgetExceeded {}

/// Indique si une erreur d'entrée-sortie est un dépassement de budget.
pub(crate) fn is_budget_exceeded(err: &io::Error) -> bool {
    err.get_ref().is_some_and(|e| e.is::<BudgetExceeded>())
}

/// Compteur partagé des octets lus depuis le début de l'enregistrement en cours.
#[derive(Clone)]
pub(crate) struct Budget {
    used: Arc<AtomicUsize>,
    limit: usize,
}

impl Budget {
    pub(crate) fn new(max_record_bytes: usize) -> Self {
        Self {
            used: Arc::new(AtomicUsize::new(0)),
            // Marge d'un tampon de lecture : les octets lus d'avance ne comptent pas contre
            // l'enregistrement courant
            limit: max_record_bytes.saturating_add(READ_BUFFER),
        }
    }

    /// Ouvre un nouvel enregistrement.
    pub(crate) fn reset(&self) {
        self.used.store(0, Ordering::Relaxed);
    }
}

/// Source dont la lecture échoue au-delà du budget de l'enregistrement en cours.
pub(crate) struct Guarded<R> {
    inner: R,
    budget: Budget,
}

impl<R> Guarded<R> {
    pub(crate) fn new(inner: R, budget: Budget) -> Self {
        Self { inner, budget }
    }
}

impl<R: Read> Read for Guarded<R> {
    fn read(&mut self, buf: &mut [u8]) -> io::Result<usize> {
        if self.budget.used.load(Ordering::Relaxed) > self.budget.limit {
            return Err(io::Error::other(BudgetExceeded));
        }
        let n = self.inner.read(buf)?;
        self.budget.used.fetch_add(n, Ordering::Relaxed);
        Ok(n)
    }
}

// =============================================================================
// Suivi des lignes consommées
// =============================================================================

/// Lecture tamponnée qui compte les fins de ligne des octets réellement consommés.
pub(crate) struct LineTracking<B> {
    inner: B,
    lines: Arc<AtomicU64>,
}

impl<B> LineTracking<B> {
    pub(crate) fn new(inner: B, lines: Arc<AtomicU64>) -> Self {
        Self { inner, lines }
    }
}

impl<B: BufRead> Read for LineTracking<B> {
    fn read(&mut self, buf: &mut [u8]) -> io::Result<usize> {
        let available = self.fill_buf()?;
        let n = buf.len().min(available.len());
        buf[..n].copy_from_slice(&available[..n]);
        self.consume(n);
        Ok(n)
    }
}

impl<B: BufRead> BufRead for LineTracking<B> {
    fn fill_buf(&mut self) -> io::Result<&[u8]> {
        self.inner.fill_buf()
    }

    fn consume(&mut self, amt: usize) {
        if let Ok(available) = self.inner.fill_buf() {
            let consumed = &available[..amt.min(available.len())];
            let newlines = consumed.iter().filter(|&&b| b == b'\n').count() as u64;
            self.lines.fetch_add(newlines, Ordering::Relaxed);
        }
        self.inner.consume(amt);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn decode(bytes: &[u8], encoding: SourceEncoding) -> io::Result<String> {
        let mut out = String::new();
        Decoded::new(bytes, encoding).read_to_string(&mut out)?;
        Ok(out)
    }

    #[test]
    fn utf8_bom_is_removed_and_text_kept() {
        assert_eq!(
            decode(b"\xEF\xBB\xBFr\xC3\xA9f", SourceEncoding::Utf8).unwrap(),
            "réf"
        );
        assert_eq!(decode(b"ref", SourceEncoding::Utf8).unwrap(), "ref");
    }

    #[test]
    fn windows_1252_and_latin1_are_decoded() {
        assert_eq!(
            decode(b"caf\xE9 \x80", SourceEncoding::Windows1252).unwrap(),
            "café €"
        );
        assert_eq!(
            decode(b"caf\xE9", SourceEncoding::Iso8859_1).unwrap(),
            "café"
        );
        // En Latin-1 strict, 0x80 est un caractère de contrôle, pas l'euro
        assert_eq!(
            decode(b"\x80", SourceEncoding::Iso8859_1).unwrap(),
            "\u{80}"
        );
    }
}
