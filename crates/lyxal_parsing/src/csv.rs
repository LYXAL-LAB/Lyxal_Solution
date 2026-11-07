//! Lecteur CSV : bibliothèque `csv`, séparateur détecté sur l'en-tête (hors guillemets), champs
//! entre guillemets sur plusieurs lignes, rejets explicites.

use std::io::{BufRead, BufReader, Chain, Cursor, Read};

use crate::common::{
    is_budget_exceeded, Budget, Decoded, Guarded, Limits, ParseError, Position, ReadFailure,
    Rejection, RejectionKind, SourceEncoding, READ_BUFFER,
};

/// Séparateur des champs.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub enum Delimiter {
    /// Détecté sur la ligne d'en-tête parmi `;`, `,`, tabulation et `|` (le plus fréquent hors
    /// guillemets ; `;` si aucun).
    #[default]
    Auto,
    /// Séparateur imposé.
    Byte(u8),
}

/// Options du lecteur CSV.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct CsvOptions {
    /// Séparateur des champs.
    pub delimiter: Delimiter,
    /// Encodage déclaré de la source.
    pub encoding: SourceEncoding,
    /// Limites par enregistrement.
    pub limits: Limits,
}

/// Enregistrement CSV : valeurs telles que lues (sans `trim`), associées à leur colonne.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CsvRecord {
    /// Position dans la source (ligne de début de l'enregistrement).
    pub position: Position,
    /// Couples (colonne de l'en-tête, valeur), dans l'ordre des colonnes.
    pub fields: Vec<(String, String)>,
}

impl CsvRecord {
    /// Valeur de la colonne `column` (nom exact de l'en-tête).
    pub fn get(&self, column: &str) -> Option<&str> {
        self.fields
            .iter()
            .find(|(name, _)| name == column)
            .map(|(_, value)| value.as_str())
    }
}

type Source<R> = Chain<Cursor<Vec<u8>>, BufReader<Guarded<Decoded<R>>>>;

/// Lecteur CSV en flux : chaque élément est un enregistrement, un rejet (la lecture continue)
/// ou une erreur d'arrêt (dernier élément).
pub struct CsvReader<R: Read> {
    reader: csv::Reader<Source<R>>,
    headers: Vec<String>,
    delimiter: u8,
    record: csv::ByteRecord,
    budget: Budget,
    limits: Limits,
    count: u64,
    last_line: Option<u64>,
    done: bool,
}

impl<R: Read> CsvReader<R> {
    /// Ouvre la source et lit son en-tête : un en-tête absent, une colonne vide ou en double
    /// arrêtent la lecture ([`ParseError::Header`]).
    pub fn new(source: R, options: CsvOptions) -> Result<Self, ParseError> {
        let limits = options.limits;
        let budget = Budget::new(limits.max_record_bytes);
        let mut buffered = BufReader::with_capacity(
            READ_BUFFER,
            Guarded::new(Decoded::new(source, options.encoding), budget.clone()),
        );
        let header_line = read_header_line(&mut buffered, limits.max_record_bytes)?;
        if header_line.iter().all(|b| b.is_ascii_whitespace()) {
            return Err(ParseError::Header {
                detail: "source vide : la ligne d'en-tête est absente".to_string(),
            });
        }
        let delimiter = match options.delimiter {
            Delimiter::Byte(byte) => byte,
            Delimiter::Auto => detect_delimiter(&header_line),
        };
        budget.reset();
        let mut reader = csv::ReaderBuilder::new()
            .delimiter(delimiter)
            .has_headers(true)
            .flexible(true)
            .from_reader(Cursor::new(header_line).chain(buffered));
        let headers = read_headers(&mut reader, limits)?;
        Ok(Self {
            reader,
            headers,
            delimiter,
            record: csv::ByteRecord::new(),
            budget,
            limits,
            count: 0,
            last_line: Some(1),
            done: false,
        })
    }

    /// Colonnes de l'en-tête, telles que lues.
    pub fn headers(&self) -> &[String] {
        &self.headers
    }

    /// Séparateur utilisé (imposé ou détecté).
    pub fn delimiter(&self) -> u8 {
        self.delimiter
    }

    fn reject(&self, position: Position, kind: RejectionKind, detail: String) -> ReadFailure {
        ReadFailure::Rejected(Rejection {
            position,
            kind,
            detail,
        })
    }

    fn fatal(&mut self, error: csv::Error) -> ReadFailure {
        self.done = true;
        let line = self.last_line;
        ReadFailure::Fatal(match error.into_kind() {
            csv::ErrorKind::Io(io) if is_budget_exceeded(&io) => ParseError::Limit {
                line,
                detail: format!(
                    "enregistrement de plus de {} octets",
                    self.limits.max_record_bytes
                ),
            },
            csv::ErrorKind::Io(io) if io.kind() == std::io::ErrorKind::InvalidData => {
                ParseError::Encoding {
                    line,
                    detail: io.to_string(),
                }
            }
            csv::ErrorKind::Io(io) => ParseError::Io(io),
            other => ParseError::Syntax {
                line,
                detail: format!("{other:?}"),
            },
        })
    }
}

impl<R: Read> Iterator for CsvReader<R> {
    type Item = Result<CsvRecord, ReadFailure>;

    fn next(&mut self) -> Option<Self::Item> {
        if self.done {
            return None;
        }
        self.budget.reset();
        match self.reader.read_byte_record(&mut self.record) {
            Ok(false) => {
                self.done = true;
                None
            }
            Err(error) => Some(Err(self.fatal(error))),
            Ok(true) => {
                self.count += 1;
                let line = self.record.position().map(|p| p.line());
                self.last_line = line.or(self.last_line);
                let position = Position {
                    record: self.count,
                    line,
                };
                let found = self.record.len();
                if found > self.limits.max_fields {
                    return Some(Err(self.reject(
                        position,
                        RejectionKind::TooManyFields,
                        format!("{found} champs (maximum {})", self.limits.max_fields),
                    )));
                }
                if self.record.as_slice().len() > self.limits.max_record_bytes {
                    return Some(Err(self.reject(
                        position,
                        RejectionKind::RecordTooLarge,
                        format!(
                            "enregistrement de plus de {} octets",
                            self.limits.max_record_bytes
                        ),
                    )));
                }
                if found != self.headers.len() {
                    return Some(Err(self.reject(
                        position,
                        RejectionKind::CsvFieldCount,
                        format!(
                            "{found} champs au lieu des {} colonnes de l'en-tête",
                            self.headers.len()
                        ),
                    )));
                }
                let mut fields = Vec::with_capacity(found);
                for (index, (name, raw)) in self.headers.iter().zip(self.record.iter()).enumerate()
                {
                    match std::str::from_utf8(raw) {
                        Ok(value) => fields.push((name.clone(), value.to_string())),
                        Err(_) => {
                            return Some(Err(self.reject(
                                position,
                                RejectionKind::InvalidText,
                                format!(
                                "colonne {} ({name}) : texte non décodable dans l'encodage déclaré",
                                index + 1
                            ),
                            )))
                        }
                    }
                }
                Some(Ok(CsvRecord { position, fields }))
            }
        }
    }
}

/// Lit la ligne d'en-tête (jusqu'à la première fin de ligne hors guillemets), fin de ligne
/// comprise, sans dépasser `max_bytes`.
fn read_header_line<B: BufRead>(input: &mut B, max_bytes: usize) -> Result<Vec<u8>, ParseError> {
    let mut line = Vec::new();
    let mut in_quotes = false;
    loop {
        let available = match input.fill_buf() {
            Ok(available) => available,
            Err(error) if error.kind() == std::io::ErrorKind::Interrupted => continue,
            Err(error) if error.kind() == std::io::ErrorKind::InvalidData => {
                return Err(ParseError::Encoding {
                    line: Some(1),
                    detail: error.to_string(),
                })
            }
            Err(error) => return Err(ParseError::Io(error)),
        };
        if available.is_empty() {
            return Ok(line);
        }
        let mut taken = 0;
        let mut complete = false;
        for &byte in available {
            taken += 1;
            if byte == b'"' {
                in_quotes = !in_quotes;
            } else if byte == b'\n' && !in_quotes {
                complete = true;
                break;
            }
        }
        line.extend_from_slice(&available[..taken]);
        input.consume(taken);
        if line.len() > max_bytes {
            return Err(ParseError::Header {
                detail: format!("ligne d'en-tête de plus de {max_bytes} octets"),
            });
        }
        if complete {
            return Ok(line);
        }
    }
}

/// Séparateur le plus fréquent hors guillemets parmi `;`, `,`, tabulation et `|`.
fn detect_delimiter(header_line: &[u8]) -> u8 {
    const CANDIDATES: [u8; 4] = *b";,\t|";
    let mut counts = [0usize; 4];
    let mut in_quotes = false;
    for &byte in header_line {
        if byte == b'"' {
            in_quotes = !in_quotes;
        } else if !in_quotes {
            if let Some(index) = CANDIDATES.iter().position(|&c| c == byte) {
                counts[index] += 1;
            }
        }
    }
    let mut best = 0;
    for index in 1..CANDIDATES.len() {
        if counts[index] > counts[best] {
            best = index;
        }
    }
    CANDIDATES[best]
}

/// Colonnes de l'en-tête : texte décodable, non vides, sans doublon.
fn read_headers<S: Read>(
    reader: &mut csv::Reader<S>,
    limits: Limits,
) -> Result<Vec<String>, ParseError> {
    let raw = reader.byte_headers().map_err(|error| ParseError::Header {
        detail: error.to_string(),
    })?;
    if raw.len() > limits.max_fields {
        return Err(ParseError::Header {
            detail: format!("{} colonnes (maximum {})", raw.len(), limits.max_fields),
        });
    }
    let mut headers: Vec<String> = Vec::with_capacity(raw.len());
    for (index, name) in raw.iter().enumerate() {
        let name = std::str::from_utf8(name).map_err(|_| ParseError::Header {
            detail: format!(
                "colonne {} : texte non décodable dans l'encodage déclaré",
                index + 1
            ),
        })?;
        if name.trim().is_empty() {
            return Err(ParseError::Header {
                detail: format!("colonne {} : nom vide", index + 1),
            });
        }
        if headers.iter().any(|existing| existing == name) {
            return Err(ParseError::Header {
                detail: format!("colonne {} : nom « {name} » en double", index + 1),
            });
        }
        headers.push(name.to_string());
    }
    Ok(headers)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn delimiter_is_detected_outside_quotes() {
        assert_eq!(detect_delimiter(b"a;b;c\n"), b';');
        assert_eq!(detect_delimiter(b"\"a;b\",c,d\n"), b',');
        assert_eq!(detect_delimiter(b"a\tb\n"), b'\t');
        assert_eq!(detect_delimiter(b"seule\n"), b';');
    }
}
