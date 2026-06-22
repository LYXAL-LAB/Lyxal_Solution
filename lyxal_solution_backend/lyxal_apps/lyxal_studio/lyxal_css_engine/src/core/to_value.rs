use crate::schema::{StyleValue, ImageSource, ShadowPosition};

pub type TransformValue = Box<dyn Fn(&StyleValue) -> Option<StyleValue>>;

pub fn to_value(style_value: Option<&StyleValue>, transform: Option<&TransformValue>) -> String {
    let style_value = match style_value {
        Some(v) => v,
        None => return "".to_string(),
    };

    let transformed = transform.and_then(|t| t(style_value));
    let value = transformed.as_ref().unwrap_or(style_value);

    match value {
        StyleValue::Unit { value, unit, .. } => {
            if unit == "number" {
                value.to_string()
            } else {
                format!("{}{}", value, unit)
            }
        }
        StyleValue::FontFamily { value, .. } => {
            value.iter()
                .map(|f| if f.contains(' ') { format!("\"{}\"", f) } else { f.clone() })
                .collect::<Vec<_>>()
                .join(", ")
        }
        StyleValue::Var { value, fallback, hidden, .. } => {
            if *hidden == Some(true) {
                return "".to_string();
            }
            let fallback_str = match fallback {
                Some(f) => format!(", {}", to_value(Some(f), transform)),
                None => "".to_string(),
            };
            format!("var(--{}{})", value, fallback_str)
        }
        StyleValue::Keyword { value, hidden, .. } => {
            if *hidden == Some(true) {
                return "".to_string();
            }
            value.clone()
        }
        StyleValue::Invalid { value, .. } => value.clone(),
        StyleValue::Unset { value, .. } => value.clone(),
        StyleValue::Rgb { r, g, b, alpha, .. } => {
            format!("rgb({} {} {} / {})", r, g, b, alpha)
        }
        StyleValue::Color { color_space, components, alpha, .. } => {
            let (mut c1, mut c2, mut c3) = *components;
            match color_space.as_str() {
                "srgb" => {
                    c1 = (c1 * 255.0).round();
                    c2 = (c2 * 255.0).round();
                    c3 = (c3 * 255.0).round();
                    format!("rgb({} {} {} / {})", c1, c2, c3, alpha)
                }
                "hsl" => format!("hsl({} {}% {}% / {})", c1, c2, c3, alpha),
                "hwb" => format!("hwb({} {}% {}% / {})", c1, c2, c3, alpha),
                "lab" => format!("lab({}% {} {} / {})", c1, c2, c3, alpha),
                "lch" => format!("lch({}% {} {} / {})", c1, c2, c3, alpha),
                "oklab" => format!("oklab({} {} {} / {})", c1, c2, c3, alpha),
                "oklch" => format!("oklch({} {} {} / {})", c1, c2, c3, alpha),
                _ => format!("color({} {} {} {} / {})", color_space, c1, c2, c3, alpha),
            }
        }
        StyleValue::Image { value, hidden, .. } => {
            if *hidden == Some(true) {
                return "none".to_string();
            }
            match value {
                ImageSource::Url { url } => format!("url(\"{}\")", url),
                _ => "none".to_string(),
            }
        }
        StyleValue::Unparsed { value, hidden, .. } => {
            if *hidden == Some(true) {
                return "none".to_string();
            }
            value.clone()
        }
        StyleValue::Layers { value, .. } => {
            let res = value.iter()
                .filter(|l| !is_hidden(l))
                .map(|l| to_value(Some(l), transform))
                .collect::<Vec<_>>()
                .join(", ");
            if res.is_empty() { "none".to_string() } else { res }
        }
        StyleValue::Tuple { value, hidden, .. } => {
            if *hidden == Some(true) {
                return "none".to_string();
            }
            value.iter()
                .filter(|v| !is_hidden(v))
                .map(|v| to_value(Some(v), transform))
                .collect::<Vec<_>>()
                .join(" ")
        }
        StyleValue::Shadow { position, offset_x, offset_y, blur, spread, color, hidden, .. } => {
            if *hidden == Some(true) {
                return "none".to_string();
            }
            let mut shadow = format!("{} {}", to_value(Some(offset_x), transform), to_value(Some(offset_y), transform));
            if let Some(b) = blur { shadow.push_str(&format!(" {}", to_value(Some(b), transform))); }
            if let Some(s) = spread { shadow.push_str(&format!(" {}", to_value(Some(s), transform))); }
            if let Some(c) = color { shadow.push_str(&format!(" {}", to_value(Some(c), transform))); }
            if *position == ShadowPosition::Inset { shadow.push_str(" inset"); }
            shadow
        }
        StyleValue::Function { name, args, hidden, .. } => {
            if *hidden == Some(true) {
                return "".to_string();
            }
            format!("{}({})", name, to_value(Some(args), transform))
        }
        StyleValue::GuaranteedInvalid { .. } => "".to_string(),
    }
}

pub fn is_hidden(v: &StyleValue) -> bool {
    match v {
        StyleValue::Unit { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::Keyword { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::Unparsed { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::FontFamily { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::Rgb { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::Color { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::Function { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::Image { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::GuaranteedInvalid { hidden } => hidden.unwrap_or(false),
        StyleValue::Invalid { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::Unset { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::Var { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::Tuple { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::Shadow { hidden, .. } => hidden.unwrap_or(false),
        StyleValue::Layers { hidden, .. } => hidden.unwrap_or(false),
    }
}

