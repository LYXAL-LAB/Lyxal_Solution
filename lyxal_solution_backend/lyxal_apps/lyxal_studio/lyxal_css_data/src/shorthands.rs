use std::collections::HashMap;
use lazy_static::lazy_static;

lazy_static! {
    pub static ref SHORTHAND_NAMES: Vec<String> = {
        let json = include_str!("shorthand_names.json");
        serde_json::from_str(json).expect("Failed to parse shorthand_names.json")
    };

    pub static ref SHORTHAND_MAP: HashMap<&'static str, Vec<&'static str>> = {
        let mut m = HashMap::new();
        // Common shorthand expansions ported from Webstudio logic
        m.insert("margin", vec!["margin-top", "margin-right", "margin-bottom", "margin-left"]);
        m.insert("padding", vec!["padding-top", "padding-right", "padding-bottom", "padding-left"]);
        m.insert("border", vec!["border-width", "border-style", "border-color"]);
        m.insert("border-top", vec!["border-top-width", "border-top-style", "border-top-color"]);
        m.insert("border-right", vec!["border-right-width", "border-right-style", "border-right-color"]);
        m.insert("border-bottom", vec!["border-bottom-width", "border-bottom-style", "border-bottom-color"]);
        m.insert("border-left", vec!["border-left-width", "border-left-style", "border-left-color"]);
        m.insert("border-width", vec!["border-top-width", "border-right-width", "border-bottom-width", "border-left-width"]);
        m.insert("border-style", vec!["border-top-style", "border-right-style", "border-bottom-style", "border-left-style"]);
        m.insert("border-color", vec!["border-top-color", "border-right-color", "border-bottom-color", "border-left-color"]);
        m.insert("border-radius", vec!["border-top-left-radius", "border-top-right-radius", "border-bottom-right-radius", "border-bottom-left-radius"]);
        m.insert("inset", vec!["top", "right", "bottom", "left"]);
        m.insert("flex", vec!["flex-grow", "flex-shrink", "flex-basis"]);
        m.insert("gap", vec!["row-gap", "column-gap"]);
        m.insert("outline", vec!["outline-width", "outline-style", "outline-color"]);
        m.insert("overflow", vec!["overflow-x", "overflow-y"]);
        m
    };
}

pub struct ShorthandEngine;
impl ShorthandEngine {
    pub fn is_shorthand(prop: &str) -> bool {
        SHORTHAND_NAMES.contains(&prop.to_string()) || SHORTHAND_MAP.contains_key(prop)
    }
    pub fn expand(prop: &str) -> Option<&Vec<&'static str>> {
        SHORTHAND_MAP.get(prop)
    }
}
