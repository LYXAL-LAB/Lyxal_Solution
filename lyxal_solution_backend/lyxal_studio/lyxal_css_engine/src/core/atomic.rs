use crate::core::rules::NestingRule;
use crate::core::to_value::{to_value, TransformValue};
use std::collections::HashMap;

pub fn generate_atomic(_nesting_rules: Vec<NestingRule>, _transform: Option<&TransformValue>) -> (String, HashMap<String, Vec<String>>) {
    let classes: HashMap<String, Vec<String>> = HashMap::new();
    // Complex atomic generation logic from atomic.ts would go here
    ("".to_string(), classes)
}


