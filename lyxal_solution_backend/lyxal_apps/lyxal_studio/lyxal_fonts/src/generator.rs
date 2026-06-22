use crate::schema::{FontMeta, FontFormat};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct FontFace {
    pub font_family: String,
    pub font_display: String,
    pub src: String,
    pub font_style: Option<String>,
    pub font_weight: Option<String>,
    pub font_stretch: Option<String>,
}

pub fn get_font_faces(assets: Vec<(String, FontFormat, FontMeta)>, base_url: &str) -> Vec<FontFace> {
    let mut faces: HashMap<String, FontFace> = HashMap::new();

    for (name, format, meta) in assets {
        let url = format!("{}{}", base_url, name);
        let key = match &meta {
            FontMeta::Static { family, style, weight } => format!("{}{}{}", family, style, weight),
            FontMeta::Variable { family, .. } => family.clone(),
        };

        let format_str = match format {
            FontFormat::Ttf => "truetype",
            FontFormat::Woff => "woff",
            FontFormat::Woff2 => "woff2",
        };

        // FIXED: Using raw strings for CSS URL formatting to avoid quote collisions
        let src_fragment = format!(r#"url("{}") format("{}")"#, url, format_str);

        if let Some(existing) = faces.get_mut(&key) {
            existing.src.push_str(&format!(", {}", src_fragment));
        } else {
            let mut face = FontFace {
                font_family: match &meta { FontMeta::Static { family, .. } => family.clone(), FontMeta::Variable { family, .. } => family.clone() },
                font_display: "swap".into(),
                src: src_fragment,
                font_style: None,
                font_weight: None,
                font_stretch: None,
            };

            match meta {
                FontMeta::Static { style, weight, .. } => {
                    face.font_style = Some(style);
                    face.font_weight = Some(weight.to_string());
                },
                FontMeta::Variable { variation_axes, .. } => {
                    face.font_style = Some("normal".into());
                    if let Some(wght) = variation_axes.get("wght") {
                        face.font_weight = Some(format!("{} {}", wght.min, wght.max));
                    }
                    if let Some(wdth) = variation_axes.get("wdth") {
                        face.font_stretch = Some(format!("{}% {}%", wdth.min, wdth.max));
                    }
                }
            }
            faces.insert(key, face);
        }
    }
    faces.into_values().collect()
}



