pub fn hyphenate_property(property: &str) -> String {
    let mut result = String::new();
    for (i, c) in property.chars().enumerate() {
        if c.is_uppercase() {
            if i != 0 {
                result.push('-');
            }
            result.push(c.to_ascii_lowercase());
        } else {
            result.push(c);
        }
    }
    result
}

