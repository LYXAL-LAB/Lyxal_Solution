use lyxal_image::templates::{Template, Preset, ParamDef, ParamType, resolve};
use lyxal_image::pipeline::LayerConfig;
use std::collections::HashMap;
use serde_json::json;

#[test]
fn test_template_resolution_defaults() {
    // 1. Define Template
    let mut params = HashMap::new();
    params.insert("title_text".to_string(), ParamDef { 
        type_: ParamType::Text, 
        default: Some(json!("Default Title")) 
    });
    params.insert("bg_color".to_string(), ParamDef { 
        type_: ParamType::Color, 
        default: Some(json!("#FFFFFF")) 
    });

    let layers = vec![
        json!({
            "type": "text",
            "params": {
                "text": "{{title_text}}",
                "box": { "width": 100, "height": 100 }
            }
        }),
        json!({
            "type": "shape_rect",
            "params": {
                "fill": "{{bg_color}}",
                "width": 100, "height": 100
            }
        })
    ];

    let template = Template {
        id: "test_tpl".to_string(),
        layers,
        params
    };

    // 2. Resolve without preset
    let resolved = resolve(&template, None).expect("Resolution failed");

    // 3. Verify
    assert_eq!(resolved.len(), 2);
    
    // Check Text Layer
    if let Some(p) = &resolved[0].params {
        assert_eq!(p.get("text").unwrap().as_str().unwrap(), "Default Title");
    } else {
        panic!("Missing params on layer 0");
    }

    // Check Shape Layer
    if let Some(p) = &resolved[1].params {
        assert_eq!(p.get("fill").unwrap().as_str().unwrap(), "#FFFFFF");
    }
}

#[test]
fn test_template_resolution_preset() {
    // 1. Define Template
    let mut params = HashMap::new();
    params.insert("width".to_string(), ParamDef { 
        type_: ParamType::Number, 
        default: Some(json!(100)) 
    });

    let layers = vec![
        json!({
            "type": "shape_rect",
            "params": {
                "width": "{{width}}", // String placeholder for number
                "height": 50
            }
        })
    ];

    let template = Template {
        id: "test_numeric".to_string(),
        layers,
        params
    };

    // 2. Define Preset
    let mut values = HashMap::new();
    values.insert("width".to_string(), json!(500)); // Override default 100

    let preset = Preset {
        template_id: "test_numeric".to_string(),
        values
    };

    // 3. Resolve
    let resolved = resolve(&template, Some(&preset)).expect("Resolution failed");

    // 4. Verify
    let p = resolved[0].params.as_ref().unwrap();
    let w = p.get("width").unwrap();
    
    // Should be a NUMBER 500, not string "500"
    assert!(w.is_number());
    assert_eq!(w.as_u64().unwrap(), 500);
}

#[test]
fn test_partial_string_interpolation() {
    let mut params = HashMap::new();
    params.insert("name".to_string(), ParamDef { 
        type_: ParamType::Text, 
        default: Some(json!("Lyxal")) 
    });

    let layers = vec![
        json!({
            "type": "text",
            "params": {
                "text": "Hello {{name}}!",
                "box": { "width": 100, "height": 100 }
            }
        })
    ];

    let template = Template {
        id: "interpolation".to_string(),
        layers,
        params
    };

    let resolved = resolve(&template, None).expect("Resolution failed");
    
    let p = resolved[0].params.as_ref().unwrap();
    assert_eq!(p.get("text").unwrap().as_str().unwrap(), "Hello Lyxal!");
}

#[test]
fn test_missing_param_error() {
    let mut params = HashMap::new();
    params.insert("required".to_string(), ParamDef { 
        type_: ParamType::Text, 
        default: None // No default!
    });

    let template = Template {
        id: "missing".to_string(),
        layers: vec![],
        params
    };

    let res = resolve(&template, None);
    assert!(res.is_err());
    let err = res.err().unwrap().to_string();
    assert!(err.contains("Missing required parameter"));
}

#[test]
fn test_type_mismatch_error() {
    let mut params = HashMap::new();
    params.insert("num".to_string(), ParamDef { 
        type_: ParamType::Number, 
        default: Some(json!(10)) 
    });

    let template = Template {
        id: "type_check".to_string(),
        layers: vec![],
        params
    };

    // Pass string "bad" for Number param
    let mut values = HashMap::new();
    values.insert("num".to_string(), json!("bad"));

    let preset = Preset {
        template_id: "type_check".to_string(),
        values
    };

    let res = resolve(&template, Some(&preset));
    assert!(res.is_err());
    assert!(res.err().unwrap().to_string().contains("expected type Number"));
}
