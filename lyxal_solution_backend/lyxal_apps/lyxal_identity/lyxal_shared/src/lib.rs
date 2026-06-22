//! Lyxal Shared - 1:1 Logto Shared Parity
//! Universal utilities for ID, masking, phone validation, etc.

pub mod database;
pub mod utils;
pub mod types;

pub mod logto_utils {
    use serde_json::Value;

    /// 1:1 Logto mask logic
    pub fn mask_string(s: &str) -> String {
        if s.len() <= 4 { return "****".to_string(); }
        format!("{}****{}", &s[..2], &s[s.len()-2..])
    }

    /// 1:1 Logto object utility (pick/omit)
    pub fn pick_fields(obj: &Value, keys: &[&str]) -> Value {
        let mut new_obj = serde_json::Map::new();
        if let Some(map) = obj.as_object() {
            for key in keys {
                if let Some(val) = map.get(*key) {
                    new_obj.insert(key.to_string(), val.clone());
                }
            }
        }
        Value::Object(new_obj)
    }
}
