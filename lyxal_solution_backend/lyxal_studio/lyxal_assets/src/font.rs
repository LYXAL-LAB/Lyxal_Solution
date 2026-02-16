use ttf_parser::Face;

pub struct FontData {
    pub family: String,
    pub style: String,
    pub weight: u16,
    pub format: String,
}

pub fn get_font_data(data: &[u8], filename: &str) -> Result<FontData, String> {
    let face = Face::parse(data, 0).map_err(|e| e.to_string())?;
    
    let family = face.names()
        .find(|n| n.name_id == ttf_parser::name_id::FAMILY && n.is_unicode())
        .and_then(|n| n.to_string())
        .unwrap_or_else(|| filename.to_string());

    let style = if face.is_italic() { "italic" } else { "normal" };
    let weight = face.weight().to_number();

    Ok(FontData {
        family,
        style: style.to_string(),
        weight,
        format: "ttf".to_string(),
    })
}

