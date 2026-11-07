//! Lecteur XML en flux (`quick-xml`) : l'appelant nomme les éléments qui forment un
//! enregistrement ; texte, CDATA et attributs sont décodés (entités prédéfinies et numériques).
//! Aucune DTD ni entité externe n'est jamais résolue.

use std::io::{BufReader, Read};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;

use quick_xml::events::{BytesRef, BytesStart, Event};

use crate::common::{
    is_budget_exceeded, Budget, Decoded, Guarded, Limits, LineTracking, ParseError, Position,
    ReadFailure, Rejection, RejectionKind, SourceEncoding, READ_BUFFER,
};

/// Options du lecteur XML.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct XmlOptions {
    /// Noms exacts des éléments qui forment un enregistrement (ex. `ARTICLE`, `PRODUCT`) ; le
    /// choix relève du module consommateur. Un tel élément imbriqué dans un enregistrement est
    /// lu comme un champ de celui-ci.
    pub record_elements: Vec<String>,
    /// Encodage déclaré de la source (la déclaration `<?xml encoding?>` n'est pas suivie).
    pub encoding: SourceEncoding,
    /// Limites par enregistrement.
    pub limits: Limits,
}

/// Enregistrement XML : champs repérés par leur chemin relatif à l'élément d'enregistrement.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct XmlRecord {
    /// Position dans la source (ligne de la balise ouvrante).
    pub position: Position,
    /// Nom de l'élément d'enregistrement.
    pub element: String,
    /// Couples (chemin, valeur) dans l'ordre du document : `A/B` pour un élément, `A/@x` pour
    /// un attribut, `@x` pour un attribut de l'élément d'enregistrement, `.` pour son propre
    /// texte. Un élément sans enfant donne sa valeur (vide comprise) ; un élément à enfants ne
    /// donne son texte que s'il n'est pas fait que de blancs. Les éléments répétés sont gardés.
    pub fields: Vec<(String, String)>,
}

impl XmlRecord {
    /// Première valeur du chemin `path`.
    pub fn get(&self, path: &str) -> Option<&str> {
        self.fields
            .iter()
            .find(|(name, _)| name == path)
            .map(|(_, value)| value.as_str())
    }

    /// Toutes les valeurs du chemin `path`, dans l'ordre du document.
    pub fn get_all<'a>(&'a self, path: &'a str) -> impl Iterator<Item = &'a str> + 'a {
        self.fields
            .iter()
            .filter(move |(name, _)| name == path)
            .map(|(_, value)| value.as_str())
    }
}

type Source<R> = LineTracking<BufReader<Guarded<Decoded<R>>>>;

/// Élément ouvert dans l'enregistrement en cours.
struct Open {
    name: String,
    text: String,
    has_children: bool,
}

/// Enregistrement en cours de lecture.
struct Building {
    position: Position,
    element: String,
    stack: Vec<Open>,
    fields: Vec<(String, String)>,
    rejection: Option<(RejectionKind, String)>,
}

impl Building {
    fn path(&self, leaf: Option<&str>) -> String {
        let mut parts: Vec<&str> = self.stack.iter().skip(1).map(|o| o.name.as_str()).collect();
        if let Some(leaf) = leaf {
            parts.push(leaf);
        }
        if parts.is_empty() {
            ".".to_string()
        } else {
            parts.join("/")
        }
    }

    fn reject(&mut self, kind: RejectionKind, detail: String) {
        if self.rejection.is_none() {
            self.rejection = Some((kind, detail));
        }
    }

    fn push_field(&mut self, path: String, value: String, limits: &Limits) {
        if self.rejection.is_some() {
            return;
        }
        if self.fields.len() >= limits.max_fields {
            self.reject(
                RejectionKind::TooManyFields,
                format!("plus de {} champs", limits.max_fields),
            );
            return;
        }
        self.fields.push((path, value));
    }
}

/// Lecteur XML en flux : chaque élément est un enregistrement, un rejet (la lecture continue)
/// ou une erreur d'arrêt (dernier élément).
pub struct XmlReader<R: Read> {
    reader: quick_xml::Reader<Source<R>>,
    buf: Vec<u8>,
    lines: Arc<AtomicU64>,
    budget: Budget,
    options: XmlOptions,
    outer_depth: usize,
    count: u64,
    done: bool,
}

impl<R: Read> XmlReader<R> {
    /// Prépare la lecture de la source (rien n'est lu avant le premier élément demandé).
    pub fn new(source: R, options: XmlOptions) -> Self {
        let budget = Budget::new(options.limits.max_record_bytes);
        let lines = Arc::new(AtomicU64::new(0));
        let input = LineTracking::new(
            BufReader::with_capacity(
                READ_BUFFER,
                Guarded::new(Decoded::new(source, options.encoding), budget.clone()),
            ),
            lines.clone(),
        );
        let mut reader = quick_xml::Reader::from_reader(input);
        let config = reader.config_mut();
        config.check_end_names = true;
        config.expand_empty_elements = false;
        config.trim_text_start = false;
        config.trim_text_end = false;
        Self {
            reader,
            buf: Vec::new(),
            lines,
            budget,
            options,
            outer_depth: 0,
            count: 0,
            done: false,
        }
    }

    fn line(&self) -> u64 {
        self.lines.load(Ordering::Relaxed) + 1
    }

    fn fatal(&mut self, error: ParseError) -> ReadFailure {
        self.done = true;
        ReadFailure::Fatal(error)
    }

    fn map_error(&self, error: quick_xml::Error) -> ParseError {
        map_error(error, self.line(), self.options.limits.max_record_bytes)
    }

    fn is_record_element(&self, name: &str) -> bool {
        self.options.record_elements.iter().any(|n| n == name)
    }

    /// Lit le reste d'un enregistrement ouvert par `start` (sauf s'il est vide).
    fn read_record(
        &mut self,
        start: &BytesStart<'_>,
        empty: bool,
        line: u64,
    ) -> Result<Building, ParseError> {
        self.count += 1;
        let limits = self.options.limits;
        let mut building = Building {
            position: Position {
                record: self.count,
                line: Some(line),
            },
            element: element_name(start),
            stack: Vec::new(),
            fields: Vec::new(),
            rejection: None,
        };
        building.stack.push(Open {
            name: building.element.clone(),
            text: String::new(),
            has_children: false,
        });
        push_attributes(&mut building, start, &limits);
        if empty {
            building.stack.clear();
            return Ok(building);
        }
        loop {
            self.buf.clear();
            let max_record_bytes = limits.max_record_bytes;
            let event = match self.reader.read_event_into(&mut self.buf) {
                Ok(event) => event,
                Err(error) => {
                    let line = self.lines.load(Ordering::Relaxed) + 1;
                    return Err(map_error(error, line, max_record_bytes));
                }
            };
            match event {
                Event::Start(e) => {
                    if let Some(parent) = building.stack.last_mut() {
                        parent.has_children = true;
                    }
                    building.stack.push(Open {
                        name: element_name(&e),
                        text: String::new(),
                        has_children: false,
                    });
                    if building.stack.len() > limits.max_depth {
                        building.reject(
                            RejectionKind::TooDeep,
                            format!("imbrication de plus de {} niveaux", limits.max_depth),
                        );
                    }
                    push_attributes(&mut building, &e, &limits);
                }
                Event::Empty(e) => {
                    if let Some(parent) = building.stack.last_mut() {
                        parent.has_children = true;
                    }
                    let name = element_name(&e);
                    if building.stack.len() + 1 > limits.max_depth {
                        building.reject(
                            RejectionKind::TooDeep,
                            format!("imbrication de plus de {} niveaux", limits.max_depth),
                        );
                    }
                    building.stack.push(Open {
                        name: name.clone(),
                        text: String::new(),
                        has_children: false,
                    });
                    push_attributes(&mut building, &e, &limits);
                    let path = building.path(None);
                    building.stack.pop();
                    building.push_field(path, String::new(), &limits);
                }
                Event::Text(text) => {
                    if let Some(open) = building.stack.last_mut() {
                        open.text.push_str(&text.xml10_content());
                    }
                }
                Event::CData(data) => {
                    if let Some(open) = building.stack.last_mut() {
                        open.text.push_str(&data.into_inner());
                    }
                }
                Event::GeneralRef(reference) => match resolve_reference(&reference) {
                    Ok(resolved) => {
                        if let Some(open) = building.stack.last_mut() {
                            open.text.push_str(&resolved);
                        }
                    }
                    Err(detail) => building.reject(RejectionKind::XmlEntity, detail),
                },
                Event::End(_) => {
                    let path = building.path(None);
                    let Some(open) = building.stack.pop() else {
                        break;
                    };
                    if !open.has_children || !open.text.trim().is_empty() {
                        building.push_field(path, open.text, &limits);
                    }
                    if building.stack.is_empty() {
                        break;
                    }
                }
                Event::Eof => {
                    return Err(ParseError::Syntax {
                        line: Some(self.lines.load(Ordering::Relaxed) + 1),
                        detail: format!("fin du document dans l'élément « {} »", building.element),
                    })
                }
                Event::Comment(_) | Event::Decl(_) | Event::PI(_) | Event::DocType(_) => {}
            }
        }
        Ok(building)
    }

    fn next_item(&mut self) -> Option<Result<XmlRecord, ReadFailure>> {
        loop {
            if self.done {
                return None;
            }
            self.budget.reset();
            let line = self.line();
            self.buf.clear();
            let event = match self.reader.read_event_into(&mut self.buf) {
                Ok(event) => event.into_owned(),
                Err(error) => {
                    let error = self.map_error(error);
                    return Some(Err(self.fatal(error)));
                }
            };
            let (start, empty) = match event {
                Event::Start(e) => (e, false),
                Event::Empty(e) => (e, true),
                Event::End(_) => {
                    self.outer_depth = self.outer_depth.saturating_sub(1);
                    continue;
                }
                Event::Eof => {
                    self.done = true;
                    if self.outer_depth > 0 {
                        return Some(Err(ReadFailure::Fatal(ParseError::Syntax {
                            line: Some(self.line()),
                            detail: "fin du document avant la fermeture de ses éléments"
                                .to_string(),
                        })));
                    }
                    return None;
                }
                _ => continue,
            };
            if !self.is_record_element(&element_name(&start)) {
                if !empty {
                    self.outer_depth += 1;
                }
                continue;
            }
            let building = match self.read_record(&start, empty, line) {
                Ok(building) => building,
                Err(error) => return Some(Err(self.fatal(error))),
            };
            return Some(match building.rejection {
                Some((kind, detail)) => Err(ReadFailure::Rejected(Rejection {
                    position: building.position,
                    kind,
                    detail,
                })),
                None => Ok(XmlRecord {
                    position: building.position,
                    element: building.element,
                    fields: building.fields,
                }),
            });
        }
    }
}

impl<R: Read> Iterator for XmlReader<R> {
    type Item = Result<XmlRecord, ReadFailure>;

    fn next(&mut self) -> Option<Self::Item> {
        self.next_item()
    }
}

fn element_name(start: &BytesStart<'_>) -> String {
    start.name().as_ref().to_string()
}

/// Attributs d'un élément ouvert, décodés ; une entité inconnue rejette l'enregistrement.
fn push_attributes(building: &mut Building, start: &BytesStart<'_>, limits: &Limits) {
    for attribute in start.attributes() {
        let attribute = match attribute {
            Ok(attribute) => attribute,
            Err(error) => {
                building.reject(
                    RejectionKind::XmlEntity,
                    format!("attribut invalide : {error}"),
                );
                return;
            }
        };
        let name = attribute.key.as_ref().to_string();
        match attribute.normalized_value(quick_xml::XmlVersion::Implicit1_0) {
            Ok(value) => {
                let path = building.path(Some(&format!("@{name}")));
                building.push_field(path, value.into_owned(), limits);
            }
            Err(error) => {
                building.reject(
                    RejectionKind::XmlEntity,
                    format!("attribut « {name} » : {error}"),
                );
                return;
            }
        }
    }
}

/// Texte d'une référence : caractère numérique ou entité prédéfinie, sinon rejet.
fn resolve_reference(reference: &BytesRef<'_>) -> Result<String, String> {
    match reference.resolve_char_ref() {
        Ok(Some(character)) => return Ok(character.to_string()),
        Ok(None) => {}
        Err(error) => return Err(format!("référence de caractère invalide : {error}")),
    }
    let name = reference.xml10_content();
    match name.as_ref() {
        "amp" => Ok("&".to_string()),
        "lt" => Ok("<".to_string()),
        "gt" => Ok(">".to_string()),
        "apos" => Ok("'".to_string()),
        "quot" => Ok("\"".to_string()),
        other => Err(format!("entité « &{other}; » inconnue")),
    }
}

fn map_error(error: quick_xml::Error, line: u64, max_record_bytes: usize) -> ParseError {
    let line = Some(line);
    match error {
        quick_xml::Error::Io(io) if is_budget_exceeded(&io) => ParseError::Limit {
            line,
            detail: format!("enregistrement de plus de {} octets", max_record_bytes),
        },
        quick_xml::Error::Io(io) if io.kind() == std::io::ErrorKind::InvalidData => {
            ParseError::Encoding {
                line,
                detail: io.to_string(),
            }
        }
        quick_xml::Error::Io(io) => ParseError::Io(std::io::Error::new(io.kind(), io.to_string())),
        quick_xml::Error::Encoding(error) => ParseError::Encoding {
            line,
            detail: error.to_string(),
        },
        other => ParseError::Syntax {
            line,
            detail: other.to_string(),
        },
    }
}
