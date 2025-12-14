use crate::model::PdfTextElement;
use lopdf::{content::Content, Document, Object};

#[derive(Clone, Copy)]
struct TextState {
    tm: [f32; 6], // a b c d e f
    tl: f32,      // text leading (non utilisé pour l'instant)
}

impl TextState {
    fn identity() -> Self {
        Self {
            tm: [1.0, 0.0, 0.0, 1.0, 0.0, 0.0],
            tl: 0.0,
        }
    }

    fn set_tm(&mut self, values: &[f32; 6]) {
        self.tm = *values;
    }

    fn translate(&mut self, tx: f32, ty: f32) {
        self.tm[4] += tx;
        self.tm[5] += ty;
    }

    fn position(&self) -> (f32, f32) {
        (self.tm[4], self.tm[5])
    }
}

/// Parse les opérateurs texte basiques d'une page et retourne des éléments positionnés.
/// Supporte uniquement Tj, TJ, Td, Tm. Aucune gestion avancée (fonts, scaling, rotation, kerning fin).
pub fn parse_text_elements(doc: &Document, page_index: usize) -> Vec<PdfTextElement> {
    let mut elements = Vec::new();
    let pages = doc.get_pages();
    let mut numbers: Vec<u32> = pages.keys().copied().collect();
    numbers.sort_unstable();

    let page_num = match numbers.get(page_index) {
        Some(n) => *n,
        None => return elements,
    };

    let page_id = match pages.get(&page_num) {
        Some(id) => *id,
        None => return elements,
    };

    let content_bytes = match doc.get_page_content(page_id) {
        Ok(bytes) => bytes,
        Err(_) => return elements,
    };

    let content = match Content::decode(&content_bytes) {
        Ok(c) => c,
        Err(_) => return elements,
    };

    let mut state = TextState::identity();

    for op in content.operations {
        match op.operator.as_str() {
            "BT" => {
                state = TextState::identity();
            }
            "ET" => {
                state = TextState::identity();
            }
            "Td" => {
                if op.operands.len() >= 2 {
                    let dx = to_f32(&op.operands[0]);
                    let dy = to_f32(&op.operands[1]);
                    state.translate(dx, dy);
                }
            }
            "TD" => {
                if op.operands.len() >= 2 {
                    let dx = to_f32(&op.operands[0]);
                    let dy = to_f32(&op.operands[1]);
                    state.translate(dx, dy);
                }
            }
            "Tm" => {
                if op.operands.len() >= 6 {
                    // a b c d e f -> on ne garde que e, f comme position.
                    let mut tm = [0.0_f32; 6];
                    for i in 0..6 {
                        tm[i] = to_f32(&op.operands[i]);
                    }
                    state.set_tm(&tm);
                }
            }
            "Tj" => {
                if let Some(txt) = extract_text_operand(&op.operands) {
                    if !txt.is_empty() {
                        let (x, y) = state.position();
                        elements.push(PdfTextElement {
                            content: txt,
                            x,
                            y,
                        });
                    }
                }
            }
            "TJ" => {
                if let Some(txt) = extract_text_array(&op.operands) {
                    if !txt.is_empty() {
                        let (x, y) = state.position();
                        elements.push(PdfTextElement {
                            content: txt,
                            x,
                            y,
                        });
                    }
                }
            }
            _ => {}
        }
    }

    elements
}

fn to_f32(obj: &Object) -> f32 {
    match obj {
        Object::Integer(v) => *v as f32,
        Object::Real(v) => *v as f32,
        _ => 0.0,
    }
}

fn extract_text_operand(operands: &[Object]) -> Option<String> {
    operands
        .first()
        .and_then(|o| match o {
            Object::String(bytes, _) => String::from_utf8(bytes.clone()).ok(),
            _ => None,
        })
}

fn extract_text_array(operands: &[Object]) -> Option<String> {
    let arr = operands.first()?.as_array().ok()?;
    let mut buf = String::new();
    for item in arr {
        if let Object::String(bytes, _) = item {
            if let Ok(s) = String::from_utf8(bytes.clone()) {
                buf.push_str(&s);
            }
        }
    }
    Some(buf)
}

