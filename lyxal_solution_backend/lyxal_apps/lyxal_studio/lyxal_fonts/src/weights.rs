use std::collections::HashMap;
use lazy_static::lazy_static;

pub struct WeightData {
    pub label: &'static str,
    pub names: Vec<&'static str>,
}

lazy_static! {
    pub static ref FONT_WEIGHTS: HashMap<&'static str, WeightData> = {
        let mut m = HashMap::new();
        m.insert("100", WeightData { label: "Thin", names: vec!["thin", "hairline"] });
        m.insert("400", WeightData { label: "Normal", names: vec!["normal", "regular"] });
        m.insert("700", WeightData { label: "Bold", names: vec!["bold"] });
        m
    };
}

