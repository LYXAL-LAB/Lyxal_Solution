//! Lecteur JSON : tableau d'objets lu élément par élément, ou NDJSON ligne par ligne
//! (`serde_json`). Tout élément qui n'est pas un objet est rejeté, jamais ignoré.

use std::io::{BufRead, BufReader, Read};

use serde_json::{Map, Value};

use crate::common::{
    Decoded, Limits, ParseError, Position, ReadFailure, Rejection, RejectionKind, SourceEncoding,
    READ_BUFFER,
};

/// Disposition de la source.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub enum JsonLayout {
    /// Tableau si le premier caractère significatif est `[`, NDJSON sinon.
    #[default]
    Auto,
    /// Un tableau JSON d'objets.
    Array,
    /// Un objet JSON par ligne (NDJSON, JSON Lines) ; les lignes vides sont ignorées.
    Lines,
}

/// Options du lecteur JSON.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct JsonOptions {
    /// Disposition de la source.
    pub layout: JsonLayout,
    /// Encodage déclaré de la source.
    pub encoding: SourceEncoding,
    /// Limites par enregistrement.
    pub limits: Limits,
}

/// Enregistrement JSON : l'objet tel que lu.
#[derive(Debug, Clone, PartialEq)]
pub struct JsonRecord {
    /// Position dans la source (ligne où commence l'objet).
    pub position: Position,
    /// Objet lu.
    pub value: Map<String, Value>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum State {
    /// Disposition pas encore déterminée.
    Start,
    /// Dans un tableau, avant le premier élément.
    ArrayFirst,
    /// Dans un tableau, après un séparateur `,`.
    ArrayNext,
    Lines,
    Done,
}

/// Octets d'un élément, bornés : au-delà de la limite, l'élément est parcouru sans être gardé.
struct Element {
    bytes: Vec<u8>,
    oversized: bool,
    max_depth: usize,
    line: u64,
}

/// Lecteur JSON en flux : chaque élément est un enregistrement, un rejet (la lecture continue)
/// ou une erreur d'arrêt (dernier élément).
pub struct JsonReader<R: Read> {
    input: BufReader<Decoded<R>>,
    options: JsonOptions,
    state: State,
    /// Erreur d'arrêt à rendre après l'enregistrement qui la précède.
    pending: Option<ReadFailure>,
    count: u64,
    line: u64,
}

impl<R: Read> JsonReader<R> {
    /// Prépare la lecture de la source (rien n'est lu avant le premier élément demandé).
    pub fn new(source: R, options: JsonOptions) -> Self {
        Self {
            input: BufReader::with_capacity(READ_BUFFER, Decoded::new(source, options.encoding)),
            options,
            state: State::Start,
            pending: None,
            count: 0,
            line: 1,
        }
    }

    fn peek(&mut self) -> Result<Option<u8>, ParseError> {
        loop {
            match self.input.fill_buf() {
                Ok(available) => return Ok(available.first().copied()),
                Err(error) if error.kind() == std::io::ErrorKind::Interrupted => continue,
                Err(error) if error.kind() == std::io::ErrorKind::InvalidData => {
                    return Err(ParseError::Encoding {
                        line: Some(self.line),
                        detail: error.to_string(),
                    })
                }
                Err(error) => return Err(ParseError::Io(error)),
            }
        }
    }

    fn bump(&mut self, byte: u8) {
        self.input.consume(1);
        if byte == b'\n' {
            self.line += 1;
        }
    }

    /// Passe les blancs ; renvoie le prochain octet significatif sans le consommer.
    fn skip_whitespace(&mut self) -> Result<Option<u8>, ParseError> {
        while let Some(byte) = self.peek()? {
            if !byte.is_ascii_whitespace() {
                return Ok(Some(byte));
            }
            self.bump(byte);
        }
        Ok(None)
    }

    fn syntax(&mut self, detail: &str) -> ReadFailure {
        self.state = State::Done;
        ReadFailure::Fatal(ParseError::Syntax {
            line: Some(self.line),
            detail: detail.to_string(),
        })
    }

    /// Lit un élément de tableau jusqu'au `,` ou au `]` de premier niveau (consommé, rendu).
    fn read_array_element(&mut self) -> Result<(Element, u8), ParseError> {
        let mut element = Element {
            bytes: Vec::new(),
            oversized: false,
            max_depth: 0,
            line: self.line,
        };
        let mut depth = 0usize;
        let mut in_string = false;
        let mut escaped = false;
        let mut started = false;
        loop {
            let Some(byte) = self.peek()? else {
                return Err(ParseError::Syntax {
                    line: Some(self.line),
                    detail: "tableau JSON non terminé".to_string(),
                });
            };
            if !in_string && depth == 0 && (byte == b',' || byte == b']') {
                self.bump(byte);
                return Ok((element, byte));
            }
            if !started && !byte.is_ascii_whitespace() {
                started = true;
                element.line = self.line;
            }
            if in_string {
                if escaped {
                    escaped = false;
                } else if byte == b'\\' {
                    escaped = true;
                } else if byte == b'"' {
                    in_string = false;
                }
            } else {
                match byte {
                    b'"' => in_string = true,
                    b'{' | b'[' => {
                        depth += 1;
                        element.max_depth = element.max_depth.max(depth);
                    }
                    b'}' | b']' => depth = depth.saturating_sub(1),
                    _ => {}
                }
            }
            self.keep(&mut element, byte);
            self.bump(byte);
        }
    }

    /// Lit une ligne NDJSON (fin de ligne consommée, non gardée).
    fn read_line(&mut self) -> Result<Option<Element>, ParseError> {
        let mut element = Element {
            bytes: Vec::new(),
            oversized: false,
            max_depth: 0,
            line: self.line,
        };
        let mut any = false;
        while let Some(byte) = self.peek()? {
            any = true;
            self.bump(byte);
            if byte == b'\n' {
                break;
            }
            self.keep(&mut element, byte);
        }
        if !any {
            return Ok(None);
        }
        element.max_depth = nesting_depth(&element.bytes);
        Ok(Some(element))
    }

    fn keep(&self, element: &mut Element, byte: u8) {
        if element.bytes.len() < self.options.limits.max_record_bytes {
            element.bytes.push(byte);
        } else {
            element.oversized = true;
        }
    }

    /// Transforme un élément lu en enregistrement ou en rejet.
    fn record(&mut self, element: Element) -> Result<JsonRecord, ReadFailure> {
        self.count += 1;
        let position = Position {
            record: self.count,
            line: Some(element.line),
        };
        let limits = self.options.limits;
        let reject = |kind, detail: String| {
            Err(ReadFailure::Rejected(Rejection {
                position,
                kind,
                detail,
            }))
        };
        if element.oversized {
            return reject(
                RejectionKind::RecordTooLarge,
                format!("élément de plus de {} octets", limits.max_record_bytes),
            );
        }
        if element.max_depth > limits.max_depth {
            return reject(
                RejectionKind::TooDeep,
                format!(
                    "imbrication de profondeur {} (maximum {})",
                    element.max_depth, limits.max_depth
                ),
            );
        }
        if std::str::from_utf8(&element.bytes).is_err() {
            return reject(
                RejectionKind::InvalidText,
                "texte non décodable dans l'encodage déclaré".to_string(),
            );
        }
        if element.bytes.iter().all(|b| b.is_ascii_whitespace()) {
            return reject(RejectionKind::JsonSyntax, "élément vide".to_string());
        }
        match serde_json::from_slice::<Value>(&element.bytes) {
            Err(error) => reject(RejectionKind::JsonSyntax, error.to_string()),
            Ok(Value::Object(value)) => {
                if value.len() > limits.max_fields {
                    return reject(
                        RejectionKind::TooManyFields,
                        format!("{} champs (maximum {})", value.len(), limits.max_fields),
                    );
                }
                Ok(JsonRecord { position, value })
            }
            Ok(other) => reject(
                RejectionKind::JsonNotObject,
                format!("élément de type {} au lieu d'un objet", kind_label(&other)),
            ),
        }
    }

    fn next_item(&mut self) -> Option<Result<JsonRecord, ReadFailure>> {
        if let Some(failure) = self.pending.take() {
            return Some(Err(failure));
        }
        loop {
            match self.state {
                State::Done => return None,
                State::Start => {
                    let first = match self.skip_whitespace() {
                        Ok(first) => first,
                        Err(error) => return Some(Err(self.fail(error))),
                    };
                    let array = match self.options.layout {
                        JsonLayout::Array => true,
                        JsonLayout::Lines => false,
                        JsonLayout::Auto => first == Some(b'['),
                    };
                    if array {
                        if first != Some(b'[') {
                            return Some(Err(self.syntax("un tableau JSON était attendu")));
                        }
                        self.bump(b'[');
                        self.state = State::ArrayFirst;
                    } else {
                        self.state = State::Lines;
                    }
                }
                State::ArrayFirst | State::ArrayNext => {
                    if self.state == State::ArrayFirst {
                        match self.skip_whitespace() {
                            Ok(Some(b']')) => {
                                self.bump(b']');
                                return self.after_array();
                            }
                            Ok(_) => {}
                            Err(error) => return Some(Err(self.fail(error))),
                        }
                    }
                    let (element, terminator) = match self.read_array_element() {
                        Ok(read) => read,
                        Err(error) => return Some(Err(self.fail(error))),
                    };
                    let item = self.record(element);
                    if terminator == b']' {
                        // Contenu après le tableau : l'élément lu est rendu, l'erreur suit
                        if let Some(Err(failure)) = self.after_array() {
                            self.pending = Some(failure);
                        }
                    } else {
                        self.state = State::ArrayNext;
                    }
                    return Some(item);
                }
                State::Lines => {
                    let element = match self.read_line() {
                        Ok(Some(element)) => element,
                        Ok(None) => {
                            self.state = State::Done;
                            return None;
                        }
                        Err(error) => return Some(Err(self.fail(error))),
                    };
                    if element.bytes.iter().all(|b| b.is_ascii_whitespace()) && !element.oversized {
                        continue;
                    }
                    return Some(self.record(element));
                }
            }
        }
    }

    /// Fin du tableau : seuls des blancs peuvent suivre.
    fn after_array(&mut self) -> Option<Result<JsonRecord, ReadFailure>> {
        self.state = State::Done;
        match self.skip_whitespace() {
            Ok(None) => None,
            Ok(Some(_)) => Some(Err(self.syntax("contenu après la fin du tableau JSON"))),
            Err(error) => Some(Err(self.fail(error))),
        }
    }

    fn fail(&mut self, error: ParseError) -> ReadFailure {
        self.state = State::Done;
        ReadFailure::Fatal(error)
    }
}

impl<R: Read> Iterator for JsonReader<R> {
    type Item = Result<JsonRecord, ReadFailure>;

    fn next(&mut self) -> Option<Self::Item> {
        self.next_item()
    }
}

/// Profondeur maximale d'imbrication d'un texte JSON (objets et tableaux, hors chaînes).
fn nesting_depth(bytes: &[u8]) -> usize {
    let (mut depth, mut max) = (0usize, 0usize);
    let (mut in_string, mut escaped) = (false, false);
    for &byte in bytes {
        if in_string {
            if escaped {
                escaped = false;
            } else if byte == b'\\' {
                escaped = true;
            } else if byte == b'"' {
                in_string = false;
            }
            continue;
        }
        match byte {
            b'"' => in_string = true,
            b'{' | b'[' => {
                depth += 1;
                max = max.max(depth);
            }
            b'}' | b']' => depth = depth.saturating_sub(1),
            _ => {}
        }
    }
    max
}

fn kind_label(value: &Value) -> &'static str {
    match value {
        Value::Null => "null",
        Value::Bool(_) => "booléen",
        Value::Number(_) => "nombre",
        Value::String(_) => "chaîne",
        Value::Array(_) => "tableau",
        Value::Object(_) => "objet",
    }
}
