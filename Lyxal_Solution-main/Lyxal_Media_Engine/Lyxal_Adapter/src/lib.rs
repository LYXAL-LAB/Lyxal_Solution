use Lyxal_Layout::output::{Scene, SceneLayer, SceneOverflow};
use lyxal_image::pipeline::{LayerConfig, TransformOp};
use serde_json::{json, Value};

pub fn adapt_scene(scene: &Scene) -> Vec<LayerConfig> {
    scene.layers.iter().map(|l| adapt_layer(l)).collect()
}

fn adapt_layer(layer: &SceneLayer) -> LayerConfig {
    let mut params = serde_json::Map::new();
    
    // Bounds
    params.insert("x".to_string(), json!(layer.x));
    params.insert("y".to_string(), json!(layer.y));
    params.insert("width".to_string(), json!(layer.width));
    params.insert("height".to_string(), json!(layer.height));
    
    // Type specific params & defaults
    let (layer_type, type_params) = match layer.layer_type.as_str() {
        "text" => {
            // Text Layer
            params.insert("text".to_string(), json!(layer.text.clone().unwrap_or_default()));
            // Default styling for visibility
            params.insert("fill".to_string(), json!("#000000")); // Black text
            
            // Font config (default)
            params.insert("font".to_string(), json!({
                "family": "Arial",
                "size": 24.0
            }));
            
            ("text", params)
        },
        "image" => {
            // Image Layer - Content should be URL/Path
            // Lyxal_Image expects base image or path? 
            // Pipeline 'image' layer draws 'ctx.img' transformed.
            // But we want to load an image?
            // Current Lyxal_Image implementation of "image" layer type draws the *CONTEXT Source Image* transformed.
            // It suggests Lyxal Image 0.1 might just overlay the base image.
            // If we want multiple images, we might use "image" type?
            // Checking pipeline.rs: "image" -> layer_img.draw_image_transformed(&src_img, ts).
            // It clones input image.
            // So currently Lyxal_Image V1 seems to support compositing the *same* source image.
            // For a "Template button -> image PNG", we likely use cleaning shapes and text using "box" (shape_rect).
            
            ("image", params)
        },
        "box" | _ => {
            // Default to Rectangle
            // Visual debugging: Stroke black, Fill transparent (or white?)
            params.insert("stroke".to_string(), json!("#000000"));
            params.insert("stroke_width".to_string(), json!(1.0));
            // params.insert("fill".to_string(), json!("#EEEEEE")); // Light gray
            
            ("shape_rect", params)
        }
    };
    
    // Overflow Handling
    // If output has overflow hidden, we ideally want to mask.
    // Given flat list, we can't easily identify children to mask. 
    // This part is a known limitation of the current Integration (V1).
    // However, if the adapter is "Smart", it might assume z-ordering implies hierarchy? No.
    // We will ignore overflow clipping for now in the adapter unless forced.
    
    LayerConfig {
        id: layer.id.clone(),
        type_: layer_type.to_string(),
        params: Some(Value::Object(type_params)),
        opacity: Some(1.0),
        blend: Some("normal".to_string()),
        visible: Some(true),
        transform: None, // Layout handled position via x/y params? 
                         // Wait, ShapeRect takes x,y in params.
                         // Image layer uses Transform to position?
                         // pipeline.rs: ShapeRect reads x,y from params. Image reads Transform.
                         // So for "image" we might need transform.
        anchor: Some("top-left".to_string()),
        mask: None,
        effects: None,
    }
}
