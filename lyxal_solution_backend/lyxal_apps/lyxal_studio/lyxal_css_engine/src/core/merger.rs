use crate::schema::{StyleValue, CssStyleMap};
use crate::core::to_value::to_value;
use std::collections::HashSet;
use lazy_static::lazy_static;

lazy_static! {
    static ref CSS_WIDE_KEYWORDS: HashSet<&'static str> = {
        let mut s = HashSet::new();
        s.insert("initial");
        s.insert("inherit");
        s.insert("unset");
        s.insert("revert");
        s.insert("revert-layer");
        s
    };
}

fn is_longhand_value(value: Option<&StyleValue>) -> bool {
    match value {
        None => false,
        Some(StyleValue::Keyword { value, .. }) if CSS_WIDE_KEYWORDS.contains(value.as_str()) => false,
        Some(StyleValue::Var { fallback, .. }) => {
            if let Some(f) = fallback {
                if let StyleValue::Keyword { value, .. } = &**f {
                    if CSS_WIDE_KEYWORDS.contains(value.as_str()) {
                        return false;
                    }
                }
            }
            true
        }
        _ => true,
    }
}

pub fn merge_styles(style_map: &CssStyleMap) -> CssStyleMap {
    let mut new_style = style_map.clone();
    
    let borders = vec!["border-top", "border-right", "border-bottom", "border-left", "border", "outline"];
    for base in borders {
        let width_key = format!("{}-width", base);
        let style_key = format!("{}-style", base);
        let color_key = format!("{}-color", base);
        
        let width = new_style.get(&width_key);
        let style = new_style.get(&style_key);
        let color = new_style.get(&color_key);
        
        if is_longhand_value(width) && is_longhand_value(style) && is_longhand_value(color) {
            let w = width.unwrap().clone();
            let s = style.unwrap().clone();
            let c = color.unwrap().clone();
            new_style.remove(&width_key);
            new_style.remove(&style_key);
            new_style.remove(&color_key);
            new_style.insert(base.to_string(), StyleValue::Tuple { value: vec![w, s, c], hidden: None });
        }
    }

    let boxes = vec!["border", "margin", "padding"];
    for base in boxes {
        let top_key = format!("{}-top", base);
        let right_key = format!("{}-right", base);
        let bottom_key = format!("{}-bottom", base);
        let left_key = format!("{}-left", base);

        let top = new_style.get(&top_key);
        let right = new_style.get(&right_key);
        let bottom = new_style.get(&bottom_key);
        let left = new_style.get(&left_key);

        if is_longhand_value(top) && 
           to_value(top, None) == to_value(right, None) &&
           to_value(top, None) == to_value(bottom, None) &&
           to_value(top, None) == to_value(left, None) {
               let val = top.unwrap().clone();
               new_style.remove(&top_key);
               new_style.remove(&right_key);
               new_style.remove(&bottom_key);
               new_style.remove(&left_key);
               new_style.insert(base.to_string(), val);
        }
    }

    new_style
}

