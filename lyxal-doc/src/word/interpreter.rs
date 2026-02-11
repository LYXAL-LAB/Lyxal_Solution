use crate::core::Document;
use crate::core::node::{Block, Inline, RevisionType, NodeIntent};
use crate::core::meta::{Scope};
use crate::word::layout::*;
use crate::word::error::WordError;

pub struct WordInterpreter {
    heading_counters: Vec<u32>,
    footnote_counter: u32,
    current_page: u32,
    toc_requested: bool,
}

impl WordInterpreter {
    pub fn new() -> Self {
        Self {
            heading_counters: vec![0; 7],
            footnote_counter: 0,
            current_page: 1,
            toc_requested: false,
        }
    }

    pub fn interpret(&mut self, doc: &Document) -> Result<WordLayout, WordError> {
        self.heading_counters = vec![0; 7];
        self.footnote_counter = 0;
        self.current_page = 1;
        self.toc_requested = false;

        let mut footnotes = Vec::new();
        let mut current_page_body = Vec::new();

        for block in &doc.content {
            self.process_block(block, &mut current_page_body, &mut footnotes)?;
        }

        let mut pages = Vec::new();
        pages.push(WordPage {
            header: None, 
            body: current_page_body,
            footer: None,
            footnotes,
            number: self.current_page,
        });

        Ok(WordLayout {
            pages,
            metadata: WordDocumentMetadata {
                title: doc.title.clone(),
                author: doc.meta.author.clone().unwrap_or_default(),
                table_of_contents_present: self.toc_requested,
            },
        })
    }

    fn process_block(&mut self, block: &Block, current_body: &mut Vec<WordElement>, footnotes: &mut Vec<WordFootnote>) -> Result<(), WordError> {
        let is_locked = matches!(block, 
            Block::Paragraph(p) if matches!(p.meta.policy.as_ref().map(|p| &p.write), Some(Scope::Private | Scope::Restricted(_)))
        );

        match block {
            Block::Paragraph(p) => {
                let text_runs = self.process_inlines(&p.inlines, footnotes)?;
                current_body.push(WordElement::Paragraph {
                    id: p.id.clone(),
                    text_runs,
                    style: None,
                    indent_level: 0,
                    numbering: None,
                    is_locked,
                });
            }
            Block::Section(s) => {
                let level = s.level.clamp(1, 6) as usize;
                self.heading_counters[level] += 1;
                for i in (level + 1)..7 {
                    self.heading_counters[i] = 0;
                }

                let numbering = self.heading_counters[1..=level]
                    .iter()
                    .map(|c| c.to_string())
                    .collect::<Vec<_>>()
                    .join(".");

                current_body.push(WordElement::Heading {
                    id: s.id.clone(),
                    level: s.level,
                    text: format!("Section {}", numbering),
                    numbering,
                });

                for child in &s.children {
                    self.process_block(child, current_body, footnotes)?;
                }
            }
            Block::PageBreak => {
                current_body.push(WordElement::PageBreak);
                self.current_page += 1;
            }
            Block::Table(t) => {
                let mut rows = Vec::new();
                for row in &t.rows {
                    let mut cells = Vec::new();
                    for cell in &row.cells {
                        let mut cell_content = Vec::new();
                        for b in &cell.content {
                            self.process_block(b, &mut cell_content, footnotes)?;
                        }
                        cells.push(WordTableCell { content: cell_content });
                    }
                    rows.push(WordTableRow { cells });
                }
                current_body.push(WordElement::Table { id: t.id.clone(), rows });
            }
            Block::Comment(c) => {
                current_body.push(WordElement::Comment {
                    id: c.id.clone(),
                    author: c.author.clone(),
                    text: c.text.clone(),
                    target_id: c.target_id.clone(),
                });
            }
            Block::Revision(r) => {
                let mut content = Vec::new();
                for b in &r.content {
                    self.process_block(b, &mut content, footnotes)?;
                }
                current_body.push(WordElement::Revision {
                    id: r.id.clone(),
                    change_type: match r.change_type {
                        RevisionType::Insertion => "insertion".to_string(),
                        RevisionType::Deletion => "deletion".to_string(),
                        RevisionType::Modification => "modification".to_string(),
                    },
                    content,
                });
            }
            Block::SignatureSlot(s) => {
                current_body.push(WordElement::SignatureSlot {
                    id: s.id.clone(),
                    role: s.role.clone(),
                });
            }
            Block::Intent(i) => {
                if let NodeIntent::TableOfContents = i.intent {
                    self.toc_requested = true;
                }
                current_body.push(WordElement::IntentPlaceholder {
                    id: i.id.clone(),
                    intent_type: format!("{:?}", i.intent),
                    label: format!("[Emplacement : {:?}]", i.intent),
                });
            }
            Block::Shape(s) => {
                current_body.push(WordElement::Shape {
                    id: s.id.clone(),
                    shape_type: s.shape_type.clone(),
                    label: format!("[Forme : {}]", s.shape_type),
                });
            }
            _ => {} 
        }
        Ok(())
    }

    fn process_inlines(&mut self, inlines: &[Inline], footnotes: &mut Vec<WordFootnote>) -> Result<Vec<WordTextRun>, WordError> {
        let mut runs = Vec::new();
        for inline in inlines {
            match inline {
                Inline::Text(t) => {
                    runs.push(WordTextRun {
                        text: t.text.clone(),
                        bold: false,
                        italic: false,
                        underline: false,
                        strike: false,
                        style: None,
                        field_type: None,
                        is_value: false,
                        is_ref: false,
                    });
                }
                Inline::Bold(b) => {
                    let mut nested = self.process_inlines(&b.content, footnotes)?;
                    for run in &mut nested { run.bold = true; }
                    runs.extend(nested);
                }
                Inline::Italic(i) => {
                    let mut nested = self.process_inlines(&i.content, footnotes)?;
                    for run in &mut nested { run.italic = true; }
                    runs.extend(nested);
                }
                Inline::FootnoteRef(_) => {
                    self.footnote_counter += 1;
                    runs.push(WordTextRun {
                        text: format!("[{}]", self.footnote_counter),
                        bold: false,
                        italic: false,
                        underline: false,
                        strike: false,
                        style: Some("footnote-ref".to_string()),
                        field_type: None,
                        is_value: false,
                        is_ref: false,
                    });
                }
                Inline::Field(f) => {
                    let resolved_text = match f.key.as_str() {
                        "page_number" => self.current_page.to_string(),
                        "current_date" => "03/01/2026".to_string(),
                        _ => f.fallback_text.clone(),
                    };
                    runs.push(WordTextRun {
                        text: resolved_text,
                        bold: false,
                        italic: false,
                        underline: false,
                        strike: false,
                        style: Some("field".to_string()),
                        field_type: Some(f.key.clone()),
                        is_value: false,
                        is_ref: false,
                    });
                }
                Inline::Value(v) => {
                    runs.push(WordTextRun {
                        text: v.formatted_value.clone().unwrap_or_else(|| v.raw_value.clone()),
                        bold: false,
                        italic: false,
                        underline: false,
                        strike: false,
                        style: Some("value".to_string()),
                        field_type: None,
                        is_value: true,
                        is_ref: false,
                    });
                }
                Inline::CrossRef(_) => {
                    runs.push(WordTextRun {
                        text: "?".to_string(),
                        bold: false,
                        italic: false,
                        underline: true,
                        strike: false,
                        style: Some("cross-ref".to_string()),
                        field_type: None,
                        is_value: false,
                        is_ref: true,
                    });
                }
                Inline::Expression(e) => {
                    runs.push(WordTextRun {
                        text: format!("{{={}}}", e.formula),
                        bold: false,
                        italic: false,
                        underline: false,
                        strike: false,
                        style: Some("expression".to_string()),
                        field_type: None,
                        is_value: false,
                        is_ref: false,
                    });
                }
                Inline::Revision(r) => {
                    let mut nested = self.process_inlines(&r.content, footnotes)?;
                    let style = match r.change_type {
                        RevisionType::Insertion => "revision-insertion",
                        RevisionType::Deletion => "revision-deletion",
                        RevisionType::Modification => "revision-modification",
                    };
                    for run in &mut nested {
                        run.style = Some(style.to_string());
                        if matches!(r.change_type, RevisionType::Deletion) { run.strike = true; }
                        if matches!(r.change_type, RevisionType::Insertion) { run.underline = true; }
                    }
                    runs.extend(nested);
                }
                _ => {}
            }
        }
        Ok(runs)
    }
}
