use std::collections::HashMap;

pub fn get_pseudo_classes_by_tag() -> HashMap<String, Vec<String>> {
    serde_json::from_str(include_str!("pseudo-classes.json")).unwrap()
}

