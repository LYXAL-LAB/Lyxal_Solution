use crate::model::PdfTextElement;
use lopdf::{content::Content, Document, Object};
use std::collections::HashMap;

#[derive(Clone)]
struct TextState {
    tm: [f32; 6],    // a b c d e f
    font_size: f32,  // taille courante
    tl: f32,         // text leading (non utilisé pour l'instant)
    current_font: Option<String>,
}

impl TextState {
    fn identity() -> Self {
        Self {
            tm: [1.0, 0.0, 0.0, 1.0, 0.0, 0.0],
            font_size: 12.0,
            tl: 0.0,
            current_font: None,
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

struct FontMetrics {
    units_per_em: f32,
    data: Vec<u8>,
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
    let font_metrics = load_fonts_for_page(doc, page_id);

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
            "Tf" => {
                if op.operands.len() >= 2 {
                    // /FontName size Tf
                    let size = to_f32(&op.operands[1]);
                    if size > 0.0 {
                        state.font_size = size;
                    }
                    if let Some(name) = op.operands.get(0).and_then(object_name) {
                        state.current_font = Some(name);
                    }
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
                        let advance = advance_for_text(&state, &font_metrics, &txt);
                        elements.push(PdfTextElement {
                            content: txt.clone(),
                            x,
                            y,
                            font_size: state.font_size,
                        });
                        state.translate(advance, 0.0);
                    }
                }
            }
            "TJ" => {
                if let Some((txt, total_advance)) =
                    extract_text_array_with_advance(&op.operands, &state, &font_metrics)
                {
                    let (x, y) = state.position();
                    elements.push(PdfTextElement {
                        content: txt,
                        x,
                        y,
                        font_size: state.font_size,
                    });
                    state.translate(total_advance, 0.0);
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

fn extract_text_array_with_advance(
    operands: &[Object],
    state: &TextState,
    fonts: &HashMap<String, FontMetrics>,
) -> Option<(String, f32)> {
    let arr = operands.first()?.as_array().ok()?;
    let mut buf = String::new();
    let mut advance: f32 = 0.0;
    for item in arr {
        match item {
            Object::String(bytes, _) => {
                if let Ok(s) = String::from_utf8(bytes.clone()) {
                    advance += advance_for_text(state, fonts, &s);
                    buf.push_str(&s);
                }
            }
            Object::Integer(v) => {
                // TJ number is in thousandths of text space, negative values reduce spacing.
                let adj = -(*v as f32) * state.font_size / 1000.0;
                advance += adj;
            }
            Object::Real(v) => {
                let adj = -(*v as f32) * state.font_size / 1000.0;
                advance += adj;
            }
            _ => {}
        }
    }
    Some((buf, advance))
}

fn advance_for_text(state: &TextState, fonts: &HashMap<String, FontMetrics>, text: &str) -> f32 {
    let font_name = match &state.current_font {
        Some(n) => n,
        None => return text.len() as f32 * (state.font_size * 0.5),
    };
    let metrics = match fonts.get(font_name) {
        Some(m) => m,
        None => return text.len() as f32 * (state.font_size * 0.5),
    };

    let face = match ttf_parser::Face::from_slice(&metrics.data, 0) {
        Ok(f) => f,
        Err(_) => return text.len() as f32 * (state.font_size * 0.5),
    };

    let scale = if metrics.units_per_em > 0.0 {
        state.font_size / metrics.units_per_em
    } else {
        0.0
    };

    let mut total = 0.0_f32;
    for ch in text.chars() {
        if let Some(glyph) = face.glyph_index(ch) {
            if let Some(w) = face.glyph_hor_advance(glyph) {
                total += (w as f32) * scale;
            } else {
                total += state.font_size * 0.5;
            }
        } else {
            total += state.font_size * 0.5;
        }
    }
    total
}

fn load_fonts_for_page(doc: &Document, page_id: lopdf::ObjectId) -> HashMap<String, FontMetrics> {
    let mut fonts = HashMap::new();
    let (resources_opt, _) = doc.get_page_resources(page_id);
    let resources = match resources_opt {
        Some(r) => r,
        None => return fonts,
    };
    if let Ok(font_dict_obj) = resources.get(b"Font") {
        if let Ok(font_dict) = font_dict_obj.as_dict() {
            for (name, font_obj) in font_dict.iter() {
                if let Ok(font_id) = font_obj.as_reference() {
                    if let Ok(font) = doc.get_object(font_id) {
                        if let Ok(font_dict_inner) = font.as_dict() {
                            if let Some(metrics) = extract_font_metrics(doc, font_dict_inner) {
                                fonts.insert(String::from_utf8_lossy(name).to_string(), metrics);
                            }
                        }
                    }
                }
            }
        }
    }
    fonts
}

fn extract_font_metrics(doc: &Document, font_dict: &lopdf::Dictionary) -> Option<FontMetrics> {
    // Find FontDescriptor -> FontFile2
    let fd_ref = font_dict.get(b"FontDescriptor").ok()?.as_reference().ok()?;
    let fd = doc.get_object(fd_ref).ok()?.as_dict().ok()?;
    let font_file_ref = fd.get(b"FontFile2").ok()?.as_reference().ok()?;
    let stream = doc.get_object(font_file_ref).ok()?.as_stream().ok()?;
    let data = stream.content.clone();
    let face = ttf_parser::Face::from_slice(&data, 0).ok()?;
    let units_per_em = face.units_per_em() as f32;
    Some(FontMetrics { units_per_em, data })
}

fn object_name(obj: &Object) -> Option<String> {
    match obj {
        Object::Name(n) => Some(String::from_utf8_lossy(n).to_string()),
        _ => None,
    }
}

