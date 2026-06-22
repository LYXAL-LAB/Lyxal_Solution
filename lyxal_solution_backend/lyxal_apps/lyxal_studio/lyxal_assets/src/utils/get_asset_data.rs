use serde_json::{json, Value};
use image::GenericImageView;
use crate::utils::font_data::get_font_metadata;

pub fn extract_metadata(data: &[u8], content_type: &str, name: &str) -> Value {
    if content_type.starts_with("image/") {
        if let Ok(img) = image::load_from_memory(data) {
            let (w, h) = img.dimensions();
            return json!({ "width": w, "height": h });
        }
    }
    if content_type.contains("font") || name.ends_with(".ttf") || name.ends_with(".woff2") {
        return get_font_metadata(data, name);
    }
    json!({})
}

