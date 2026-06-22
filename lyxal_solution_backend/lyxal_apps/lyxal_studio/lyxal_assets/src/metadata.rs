use image::GenericImageView;
use ttf_parser::Face;
use serde_json::{json, Value};

pub fn extract_metadata(data: &[u8], content_type: &str, filename: &str) -> Value {
    if content_type.starts_with("image/") {
        if let Ok(img) = image::load_from_memory(data) {
            let (w, h) = img.dimensions();
            return json!({ "width": w, "height": h });
        }
    } else if content_type.contains("font") {
        if let Ok(face) = Face::parse(data, 0) {
            let family = face.names()
                .find(|n| n.name_id == ttf_parser::name_id::FAMILY && n.is_unicode())
                .and_then(|n| n.to_string())
                .unwrap_or_else(|| filename.to_string());
            return json!({ 
                "family": family, 
                "weight": face.weight().to_number(), 
                "style": if face.is_italic() { "italic" } else { "normal" },
                "isVariable": face.is_variable()
            });
        }
    }
    json!({})
}
