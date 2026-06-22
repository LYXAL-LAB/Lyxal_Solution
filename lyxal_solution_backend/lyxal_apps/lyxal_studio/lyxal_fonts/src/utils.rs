pub fn get_font_face_name(family: &str, weight: u32, style: &str) -> String {
    format!("{}-{}-{}", family, weight, style)
}

