use crate::core::Document;
use crate::core::node::{Block, Inline};
use crate::slides::layout::*;
use crate::slides::error::SlidesError;

pub struct SlidesInterpreter {
    slide_counter: u32,
}

impl SlidesInterpreter {
    pub fn new() -> Self {
        Self {
            slide_counter: 0,
        }
    }

    pub fn interpret(&mut self, doc: &Document) -> Result<SlidesLayout, SlidesError> {
        self.slide_counter = 0;
        let mut slides = Vec::new();

        for block in &doc.content {
            if let Block::Section(s) = block {
                self.slide_counter += 1;
                let mut elements = Vec::new();
                for child in &s.children {
                    self.process_block(child, &mut elements)?;
                }
                slides.push(Slide {
                    id: s.id.clone(),
                    elements,
                    number: self.slide_counter,
                    intent: s.meta.tags.iter().find(|t| t.key == "intent").map(|t| t.value.clone()),
                });
            }
        }

        Ok(SlidesLayout {
            slides,
            metadata: SlidesDocumentMetadata {
                title: doc.title.clone(),
                author: doc.meta.author.clone().unwrap_or_default(),
            },
        })
    }

    fn process_block(&mut self, block: &Block, elements: &mut Vec<SlideElement>) -> Result<(), SlidesError> {
        let spatial = self.extract_spatial(block);
        let appearance = self.extract_appearance(block);

        match block {
            Block::Paragraph(p) => {
                let text = self.collect_text(&p.inlines);
                elements.push(SlideElement {
                    id: p.id.clone(),
                    content: SlideContent::Text(text),
                    spatial,
                    appearance_intent: appearance,
                });
            }
            Block::Image(i) => {
                elements.push(SlideElement {
                    id: i.id.clone(),
                    content: SlideContent::Image {
                        src: i.src.clone(),
                        caption: i.caption.clone(),
                    },
                    spatial,
                    appearance_intent: appearance,
                });
            }
            Block::Shape(s) => {
                elements.push(SlideElement {
                    id: s.id.clone(),
                    content: SlideContent::Shape {
                        shape_type: s.shape_type.clone(),
                    },
                    spatial,
                    appearance_intent: appearance,
                });
            }
            Block::Table(t) => {
                elements.push(SlideElement {
                    id: t.id.clone(),
                    content: SlideContent::Table {
                        rows: t.rows.len(),
                        cols: t.rows.first().map(|r| r.cells.len()).unwrap_or(0),
                    },
                    spatial,
                    appearance_intent: appearance,
                });
            }
            Block::Group(g) => {
                let mut group_elements = Vec::new();
                for child in &g.children {
                    self.process_block(child, &mut group_elements)?;
                }
                elements.push(SlideElement {
                    id: g.id.clone(),
                    content: SlideContent::Group(group_elements),
                    spatial,
                    appearance_intent: appearance,
                });
            }
            Block::Section(s) => {
                let mut group_elements = Vec::new();
                for child in &s.children {
                    self.process_block(child, &mut group_elements)?;
                }
                elements.push(SlideElement {
                    id: s.id.clone(),
                    content: SlideContent::Group(group_elements),
                    spatial,
                    appearance_intent: appearance,
                });
            }
            _ => {}
        }
        Ok(())
    }

    fn extract_spatial(&self, block: &Block) -> SpatialProperties {
        let mut x = 0.0;
        let mut y = 0.0;
        let mut z = 0;
        let mut width = None;
        let mut height = None;

        if let Some(meta) = self.get_block_meta(block) {
            for tag in &meta.tags {
                match tag.key.as_str() {
                    "pos_x" => x = tag.value.parse().unwrap_or(0.0),
                    "pos_y" => y = tag.value.parse().unwrap_or(0.0),
                    "pos_z" => z = tag.value.parse().unwrap_or(0),
                    "width" => width = Some(tag.value.parse().unwrap_or(0.0)),
                    "height" => height = Some(tag.value.parse().unwrap_or(0.0)),
                    _ => {}
                }
            }
        }

        SpatialProperties { x, y, z, width, height }
    }

    fn extract_appearance(&self, block: &Block) -> Option<String> {
        self.get_block_meta(block).and_then(|meta| {
            meta.tags.iter().find(|t| t.key == "appearance").map(|t| t.value.clone())
        })
    }

    fn collect_text(&self, inlines: &[Inline]) -> String {
        let mut full_text = String::new();
        for inline in inlines {
            match inline {
                Inline::Text(t) => full_text.push_str(&t.text),
                Inline::Bold(b) => full_text.push_str(&self.collect_text(&b.content)),
                Inline::Italic(i) => full_text.push_str(&self.collect_text(&i.content)),
                _ => {}
            }
        }
        full_text
    }

    fn get_block_meta<'a>(&self, block: &'a Block) -> Option<&'a crate::core::Metadata> {
        match block {
            Block::Section(s) => Some(&s.meta),
            Block::Paragraph(p) => Some(&p.meta),
            Block::List(l) => Some(&l.meta),
            Block::Table(t) => Some(&t.meta),
            Block::Image(i) => Some(&i.meta),
            Block::Quote(q) => Some(&q.meta),
            Block::CodeBlock(c) => Some(&c.meta),
            Block::Anchor(a) => Some(&a.meta),
            Block::Comment(c) => Some(&c.meta),
            Block::Intent(i) => Some(&i.meta),
            Block::SignatureSlot(s) => Some(&s.meta),
            Block::Revision(r) => Some(&r.meta),
            Block::Iteration(it) => Some(&it.meta),
            Block::Condition(c) => Some(&c.meta),
            Block::Group(g) => Some(&g.meta),
            Block::Footnote(f) => Some(&f.meta),
            Block::Header(h) => Some(&h.meta),
            Block::Footer(f) => Some(&f.meta),
            Block::Shape(s) => Some(&s.meta),
            _ => None,
        }
    }
}

