use lyxal_image::{render_final, templates};
use lyxal_image::export::{ExportConfig, OutputFormat};
use serde_json::json;
use std::collections::HashMap;
use sha2::{Sha256, Digest};

fn calculate_hash(bytes: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    format!("{:x}", hasher.finalize())
}

#[test]
fn test_determinism() {
    // 1. Setup Complex Template
    let layers = vec![
        json!({
            "type": "shape_rect",
            "params": { "x": 10, "y": 10, "width": 100, "height": 100, "fill": "#FF0000" }
        }),
        json!({
            "type": "text",
            "params": { 
                "text": "Deterministic?", 
                "box": { "width": 200, "height": 50 },
                "x": 20, "y": 20
            }
        })
    ];
    
    let template = templates::Template {
        id: "golden".to_string(),
        layers,
        params: HashMap::new()
    };
    
    let cfg = ExportConfig {
        format: OutputFormat::Png,
        background_color: None
    };
    
    // 2. Render Twice
    let run_a = render_final(&template, None, &cfg).expect("Run A failed");
    let run_b = render_final(&template, None, &cfg).expect("Run B failed");
    
    // 3. Compare Bytes (Bitwise Equality)
    // PNG includes timestamps? image crate generally writes minimal png. 
    // If it fails due to metadata, we might need to decode and compare pixels.
    // But requirement is "Mêmes inputs -> mêmes outputs (bitwise si possible)".
    
    // Let's check hash.
    let hash_a = calculate_hash(&run_a);
    let hash_b = calculate_hash(&run_b);
    
    assert_eq!(hash_a, hash_b, "Output must be deterministic");
}
