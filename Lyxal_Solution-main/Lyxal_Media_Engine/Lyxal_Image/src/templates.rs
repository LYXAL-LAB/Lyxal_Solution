use std::collections::HashMap;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use crate::pipeline::LayerConfig;
use crate::error::{LyxalError, LyxalResult};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum ParamType {
    Text,
    Color,
    Number,
    Image,
    Boolean
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParamDef {
    #[serde(rename = "type")]
    pub type_: ParamType,
    pub default: Option<Value>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Template {
    pub id: String,
    // We store layers as raw JSON Value to allow keys like "width": "{{width_val}}" 
    // where "{{width_val}}" is a string, but final expected type is number.
    pub layers: Vec<Value>, 
    pub params: HashMap<String, ParamDef>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Preset {
    pub template_id: String,
    pub values: HashMap<String, Value>,
}

pub fn resolve(template: &Template, preset: Option<&Preset>) -> LyxalResult<Vec<LayerConfig>> {
    // 1. Resolve Parameter Values
    let mut resolved_values = HashMap::new();
    
    // Check template ID match if preset is provided
    if let Some(p) = preset {
        if p.template_id != template.id {
            return Err(LyxalError::InvalidParam(format!("Preset template_id '{}' mismatch with template '{}'", p.template_id, template.id)));
        }
    }

    for (key, def) in &template.params {
        let val = if let Some(p) = preset {
            p.values.get(key).or(def.default.as_ref())
        } else {
            def.default.as_ref()
        };

        if let Some(v) = val {
            validate_type(key, v, &def.type_)?;
            resolved_values.insert(key.clone(), v.clone());
        } else {
            return Err(LyxalError::InvalidParam(format!("Missing required parameter: {}", key)));
        }
    }

    // 2. Perform Substitution on Layers
    let mut resolved_layers_json = Value::Array(template.layers.clone());
    substitute_recursive(&mut resolved_layers_json, &resolved_values)?;

    // 3. Deserialize to LayerConfigs
    let layers: Vec<LayerConfig> = serde_json::from_value(resolved_layers_json)
        .map_err(|e| LyxalError::InvalidParam(format!("Template resolution produced invalid layers: {}", e)))?;

    Ok(layers)
}

fn validate_type(key: &str, value: &Value, expected: &ParamType) -> LyxalResult<()> {
    let valid = match expected {
        ParamType::Text => value.is_string(),
        ParamType::Color => value.is_string() && value.as_str().unwrap().starts_with('#'), // Basic check
        ParamType::Number => value.is_number(),
        ParamType::Boolean => value.is_boolean(),
        ParamType::Image => value.is_string(), // Image path/ID usually string
    };

    if !valid {
        return Err(LyxalError::InvalidParam(format!("Parameter '{}' expected type {:?}, got {:?}", key, expected, value)));
    }
    Ok(())
}

fn substitute_recursive(node: &mut Value, values: &HashMap<String, Value>) -> LyxalResult<()> {
    match node {
        Value::String(s) => {
            // Check for exact match "{{key}}"
            if s.starts_with("{{") && s.ends_with("}}") {
                let key = &s[2..s.len()-2];
                if let Some(val) = values.get(key) {
                    *node = val.clone(); // Replace String with Typed Value (e.g. Number)
                } 
                // If key not found in values (unlikely if validated), keep/ignore?
                // Or maybe it's a false positive? "val" is not in vars map.
                // For safety, we only replace if key is in map.
            } else {
                // Check for partial interpolation "Msg: {{key}}"
                // For MVP, simplistic check.
                if s.contains("{{") && s.contains("}}") {
                    let mut new_s = s.clone();
                    for (k, v) in values {
                        let placeholder = format!("{{{{{}}}}}", k);
                        if new_s.contains(&placeholder) {
                            if let Value::String(v_str) = v {
                                new_s = new_s.replace(&placeholder, v_str);
                            } else {
                                // Interpolating non-string into string? Convert to string.
                                new_s = new_s.replace(&placeholder, &v.to_string());
                            }
                        }
                    }
                    *node = Value::String(new_s);
                }
            }
        },
        Value::Array(arr) => {
            for v in arr {
                substitute_recursive(v, values)?;
            }
        },
        Value::Object(map) => {
            for (_, v) in map {
                substitute_recursive(v, values)?;
            }
        },
        _ => {}
    }
    Ok(())
}
