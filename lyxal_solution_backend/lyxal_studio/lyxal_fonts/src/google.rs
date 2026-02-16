pub fn get_google_fonts_url(family: &str, weights: &[u32], italic: bool) -> String {
    let mut url = format!("https://fonts.googleapis.com/css2?family={}", family.replace(" ", "+"));
    if !weights.is_empty() {
        url.push_str(":ital,wght@");
        let mut parts = Vec::new();
        for &w in weights {
            if italic { parts.push(format!("1,{}", w)); }
            parts.push(format!("0,{}", w));
        }
        parts.sort();
        url.push_str(&parts.join(";"));
    }
    url.push_str("&display=swap");
    url
}

