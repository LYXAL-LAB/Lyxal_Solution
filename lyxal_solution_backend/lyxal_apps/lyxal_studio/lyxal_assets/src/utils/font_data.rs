use ttf_parser::Face;
use serde_json::{json, Value};

pub fn get_font_metadata(data: &[u8], filename: &str) -> Value {
    if let Ok(face) = Face::parse(data, 0) {
        let family = face.names()
            .into_iter()
            .find(|n| n.name_id == ttf_parser::name_id::FAMILY && n.is_unicode())
            .and_then(|n| n.to_string())
            .unwrap_or_else(|| filename.to_string());
        
        json!({
            "family": family,
            "weight": face.weight().to_number(),
            "style": if face.is_italic() { "italic" } else { "normal" },
            "isVariable": face.is_variable()
        })
    } else {
        json!({})
    }
}
