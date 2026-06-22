use crate::schema::{StyleValue, CssStyleMap};
use crate::core::to_value::{to_value, TransformValue};
use crate::core::to_property::hyphenate_property;
use crate::core::prefixer::prefix_styles;
use crate::core::merger::merge_styles;
use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct Declaration {
    pub breakpoint: String,
    pub selector: String,
    pub property: String,
    pub value: StyleValue,
}

pub struct MixinRule {
    pub declarations: HashMap<String, Declaration>,
}

pub struct NestingRule {
    pub selector: String,
    pub descendant_suffix: String,
    pub declarations: HashMap<String, Declaration>,
    pub mixins: Vec<String>,
}

impl NestingRule {
    pub fn new(selector: String, descendant_suffix: String) -> Self {
        Self {
            selector,
            descendant_suffix,
            declarations: HashMap::new(),
            mixins: Vec::new(),
        }
    }

    pub fn set_declaration(&mut self, decl: Declaration) {
        let key = format!("{}:{}:{}", decl.breakpoint, decl.selector, decl.property);
        self.declarations.insert(key, decl);
    }

    pub fn get_merged_declarations(&self) -> Vec<Declaration> {
        let mut groups: HashMap<String, Vec<&Declaration>> = HashMap::new();
        for decl in self.declarations.values() {
            let key = format!("{}{}", decl.breakpoint, decl.selector);
            groups.entry(key).or_default().push(decl);
        }

        let mut result = Vec::new();
        for group in groups.values() {
            let mut style_map = CssStyleMap::new();
            for d in group {
                style_map.insert(d.property.clone(), d.value.clone());
            }
            let merged = merge_styles(&style_map);
            for (prop, val) in merged {
                result.push(Declaration {
                    breakpoint: group[0].breakpoint.clone(),
                    selector: group[0].selector.clone(),
                    property: prop,
                    value: val,
                });
            }
        }
        result
    }

    pub fn to_string(&self, breakpoint: &str, indent: usize, transform: Option<&TransformValue>) -> String {
        let merged = self.get_merged_declarations();
        let mut style_by_selector: HashMap<String, CssStyleMap> = HashMap::new();

        for decl in merged {
            if decl.breakpoint != breakpoint { continue; }
            let mut sel = decl.selector.clone();
            if sel == ":local-link" { sel = "[aria-current=page]".to_string(); }
            let full_sel = format!("{}{}{}", self.selector, self.descendant_suffix, sel);
            style_by_selector.entry(full_sel).or_default().insert(decl.property, decl.value);
        }

        let mut res = String::new();
        let spaces = " ".repeat(indent);
        let mut sorted_selectors: Vec<_> = style_by_selector.keys().collect();
        sorted_selectors.sort();

        for sel in sorted_selectors {
            let style = style_by_selector.get(sel).unwrap();
            let prefixed = prefix_styles(style);
            let mut content = String::new();
            for (prop, val) in prefixed {
                content.push_str(&format!("{}{}: {};\n", " ".repeat(indent + 2), hyphenate_property(&prop), to_value(Some(&val), transform)));
            }
            res.push_str(&format!("{}{}{{\n{}{}}}\n", spaces, sel, content, spaces));
        }
        res
    }
}

pub struct FontFaceOptions {
    pub font_family: String,
    pub font_style: String,
    pub font_weight: String,
    pub font_display: String,
    pub src: String,
}

pub struct FontFaceRule {
    pub options: FontFaceOptions,
}

impl FontFaceRule {
    pub fn to_string(&self) -> String {
        format!(
            "@font-face {{\n  font-family: \"{}\";\n  font-style: {};\n  font-weight: {};\n  font-display: {};\n  src: {};\n}}",
            self.options.font_family, self.options.font_style, self.options.font_weight, self.options.font_display, self.options.src
        )
    }
}

