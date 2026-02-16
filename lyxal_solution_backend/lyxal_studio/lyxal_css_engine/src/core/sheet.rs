use crate::core::rules::{NestingRule, FontFaceRule};
use crate::core::media::{MediaRuleOptions, compare_media};
use crate::core::to_value::TransformValue;
use std::collections::HashMap;

pub struct StyleSheet {
    pub nesting_rules: Vec<NestingRule>,
    pub media_rules: HashMap<String, MediaRuleOptions>,
    pub font_face_rules: Vec<FontFaceRule>,
}

impl StyleSheet {
    pub fn new() -> Self {
        Self {
            nesting_rules: Vec::new(),
            media_rules: HashMap::new(),
            font_face_rules: Vec::new(),
        }
    }

    pub fn generate(&self, transform: Option<&TransformValue>) -> String {
        let mut css = Vec::new();
        for f in &self.font_face_rules {
            css.push(f.to_string());
        }
        
        let mut sorted_media_names: Vec<_> = self.media_rules.keys().collect();
        sorted_media_names.sort_by(|a, b| compare_media(self.media_rules.get(*a).unwrap(), self.media_rules.get(*b).unwrap()));
        
        for name in sorted_media_names {
            let options = self.media_rules.get(name).unwrap();
            let mut rules = Vec::new();
            for r in &self.nesting_rules {
                let res = r.to_string(name, 2, transform);
                if !res.is_empty() { rules.push(res); }
            }
            if !rules.is_empty() {
                let cond = match &options.condition {
                    Some(c) => format!(" and ({})", c),
                    None => {
                        let mut s = String::new();
                        if let Some(min) = options.min_width { s.push_str(&format!(" and (min-width: {}px)", min)); }
                        if let Some(max) = options.max_width { s.push_str(&format!(" and (max-width: {}px)", max)); }
                        s
                    }
                };
                css.push(format!("@media {} {} {{\n{}\n}}", options.media_type.as_deref().unwrap_or("all"), cond, rules.join("\n")));
            }
        }
        
        css.join("\n")
    }
}

