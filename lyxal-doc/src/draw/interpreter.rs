use crate::core::Document;
use crate::core::node::{Block, Inline};
use crate::draw::layout::*;
use crate::draw::error::DrawError;

pub struct DrawInterpreter;

impl DrawInterpreter {
    pub fn new() -> Self {
        Self
    }

    pub fn interpret(&mut self, doc: &Document) -> Result<DrawLayout, DrawError> {
        let mut layers = Vec::new();

        // L'interprète Draw traite tout le document comme un canevas unique.
        // Les Sections de premier niveau sont des calques.
        for block in &doc.content {
            if let Block::Section(s) = block {
                let mut elements = Vec::new();
                for child in &s.children {
                    elements.push(self.process_block(child, DrawTransform::default())?);
                }
                layers.push(DrawLayer {
                    id: s.id.clone(),
                    name: format!("Layer {}", layers.len() + 1),
                    elements,
                });
            } else {
                // Éléments hors section : on les place dans un calque par défaut
                let element = self.process_block(block, DrawTransform::default())?;
                if layers.is_empty() {
                    layers.push(DrawLayer {
                        id: "default-layer".to_string(),
                        name: "Default Layer".to_string(),
                        elements: vec![element],
                    });
                } else {
                    layers[0].elements.push(element);
                }
            }
        }

        Ok(DrawLayout {
            canvas: DrawCanvas { layers },
            metadata: DrawDocumentMetadata {
                title: doc.title.clone(),
                author: doc.meta.author.clone().unwrap_or_default(),
            },
        })
    }

    fn process_block(&self, block: &Block, parent_transform: DrawTransform) -> Result<DrawElement, DrawError> {
        let local_transform = self.extract_transform(block);
        let final_transform = self.compose_transforms(parent_transform, local_transform);
        let properties = self.get_block_properties(block);

        let content = match block {
            Block::Shape(s) => {
                let points = self.extract_points(s);
                DrawContent::Shape {
                    shape_type: s.shape_type.clone(),
                    points,
                }
            }
            Block::Image(i) => DrawContent::Image {
                src: i.src.clone(),
            },
            Block::Paragraph(p) => {
                let value = self.collect_text(&p.inlines);
                DrawContent::Text { value }
            }
            Block::Group(g) => {
                let mut children = Vec::new();
                for child in &g.children {
                    children.push(self.process_block(child, final_transform.clone())?);
                }
                DrawContent::Group(children)
            }
            _ => {
                // Pour les blocs non graphiques, on crée un placeholder vide ou on ignore.
                // Ici on choisit de retourner un élément vide pour respecter la règle "Rien d'inconnu".
                DrawContent::Text { value: "[Non-Graphic Element]".to_string() }
            }
        };

        Ok(DrawElement {
            id: self.get_block_id(block),
            content,
            transform: final_transform,
            properties,
        })
    }

    fn extract_transform(&self, block: &Block) -> DrawTransform {
        let mut transform = DrawTransform::default();
        if let Some(meta) = self.get_block_meta(block) {
            for tag in &meta.tags {
                match tag.key.as_str() {
                    "translate_x" => transform.translate_x = tag.value.parse().unwrap_or(0.0),
                    "translate_y" => transform.translate_y = tag.value.parse().unwrap_or(0.0),
                    "rotate" => transform.rotate = tag.value.parse().unwrap_or(0.0),
                    "scale_x" => transform.scale_x = tag.value.parse().unwrap_or(1.0),
                    "scale_y" => transform.scale_y = tag.value.parse().unwrap_or(1.0),
                    _ => {}
                }
            }
        }
        transform
    }

    fn compose_transforms(&self, parent: DrawTransform, local: DrawTransform) -> DrawTransform {
        // Composition simplifiée pour la v1.0 (Addition des translations, rotation, multiplication des échelles)
        // Dans une v2.0, on utiliserait une vraie matrice 3x3.
        DrawTransform {
            translate_x: parent.translate_x + local.translate_x,
            translate_y: parent.translate_y + local.translate_y,
            rotate: parent.rotate + local.rotate,
            scale_x: parent.scale_x * local.scale_x,
            scale_y: parent.scale_y * local.scale_y,
        }
    }

    fn extract_points(&self, s: &crate::core::node::ShapeBlock) -> Vec<Point> {
        // Les points sont stockés dans les propriétés de la Shape sous forme de chaîne (ex: "x1,y1;x2,y2")
        let mut points = Vec::new();
        if let Some(p_str) = s.properties.get("points") {
            for pair in p_str.split(';') {
                let coords: Vec<&str> = pair.split(',').collect();
                if coords.len() == 2 {
                    let x = coords[0].trim().parse().unwrap_or(0.0);
                    let y = coords[1].trim().parse().unwrap_or(0.0);
                    points.push(Point { x, y });
                }
            }
        }
        points
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

    fn get_block_id(&self, block: &Block) -> String {
        match block {
            Block::Section(s) => s.id.clone(),
            Block::Paragraph(p) => p.id.clone(),
            Block::List(l) => l.id.clone(),
            Block::Table(t) => t.id.clone(),
            Block::Image(i) => i.id.clone(),
            Block::Quote(q) => q.id.clone(),
            Block::CodeBlock(c) => c.id.clone(),
            Block::Anchor(a) => a.id.clone(),
            Block::Comment(c) => c.id.clone(),
            Block::Intent(i) => i.id.clone(),
            Block::SignatureSlot(s) => s.id.clone(),
            Block::Revision(r) => r.id.clone(),
            Block::Iteration(it) => it.id.clone(),
            Block::Condition(c) => c.id.clone(),
            Block::Group(g) => g.id.clone(),
            Block::Footnote(f) => f.id.clone(),
            Block::Header(h) => h.id.clone(),
            Block::Footer(f) => f.id.clone(),
            Block::Shape(s) => s.id.clone(),
            _ => "unknown".to_string(),
        }
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

    fn get_block_properties(&self, block: &Block) -> std::collections::BTreeMap<String, String> {
        if let Block::Shape(s) = block {
            s.properties.clone()
        } else {
            std::collections::BTreeMap::new()
        }
    }
}

