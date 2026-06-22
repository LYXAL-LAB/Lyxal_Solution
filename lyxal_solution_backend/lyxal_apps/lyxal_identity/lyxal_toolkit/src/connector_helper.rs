//! Connector Helper - 1:1 Logto connector-kit Parity
//! Specialized utilities for connector data handling and validation.

use serde_json::Value;

/// 1:1 Logto logic for replacing handlebars in templates
pub fn replace_handlebars(template: &str, data: &Value) -> String {
    let mut result = template.to_string();
    if let Some(map) = data.as_object() {
        for (key, val) in map {
            let placeholder = format!("{{{{{}}}}}", key);
            let replacement = match val {
                Value::String(s) => s.clone(),
                _ => val.to_string(),
            };
            result = result.replace(&placeholder, &replacement);
        }
    }
    result
}
