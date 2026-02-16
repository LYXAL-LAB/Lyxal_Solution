use nanoid::nanoid;
use std::path::Path;

pub fn get_unique_filename(filename: &str) -> String {
    let id = nanoid!(21);
    let path = Path::new(filename);
    let stem = path.file_stem().and_then(|s| s.to_str()).unwrap_or("");
    let ext = path.extension().and_then(|s| s.to_str()).unwrap_or("");
    if ext.is_empty() {
        format!("{}_{}", stem, id)
    } else {
        format!("{}_{}.{}", stem, id, ext)
    }
}

