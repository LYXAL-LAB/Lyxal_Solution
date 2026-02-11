use Lyxal_Layout::{
    LayoutNode, NodeType, LayoutStyle, Dimension, Display, SizeConstraints, compute_layout, resolve_to_scene, FlexDirection, JustifyContent, AlignItems, Edges
};
use lyxal_image::{ImageContext, LyxalImage};
use lyxal_adapter::adapt_scene;
use std::fs::File;
use std::io::Write;

#[test]
fn test_e2e_render_pipeline() {
    // 1. Create Layout Tree (Button Template)
    // Container: Flex Row, Centered, Padding
    let mut button = LayoutNode::new(NodeType::Box).with_id("btn_container");
    button.style.display = Display::Flex;
    button.style.width = Dimension::Points(300.0);
    button.style.height = Dimension::Points(100.0);
    button.style.padding = Edges::all(10.0);
    button.style.justify_content = JustifyContent::Center;
    button.style.align_items = AlignItems::Center;
    // Visually: Rect
    
    // Label: Text
    let mut label = LayoutNode::new(NodeType::Text).with_id("btn_label");
    label.content = Some("Click Me".to_string());
    
    button.children.push(label);
    
    // 2. Compute Layout
    let res = compute_layout(&button, SizeConstraints::default()).unwrap();
    let scene = resolve_to_scene(&res, None);
    
    // 3. Adapt to Image Layers
    let layers = adapt_scene(&scene);
    
    // Debug: Print layers
    let layers_json_val = serde_json::json!({ "layers": layers });
    let layers_json = serde_json::to_string_pretty(&layers_json_val).unwrap();
    println!("Render Config: {}", layers_json);
    
    // 4. Render
    let ctx = ImageContext::default();
    
    // Base Canvas 800x600 (larger than button)
    let base_img = LyxalImage::new_empty(800, 600);
    let base_bytes = base_img.to_bytes(image::ImageFormat::Png).unwrap();
    
    let res_bytes = lyxal_image::process(&base_bytes, &layers_json, ctx).expect("Render failed");
    
    // 5. Verify Output
    assert!(res_bytes.len() > 100);
    // Magic bytes for PNG: 89 50 4E 47 0D 0A 1A 0A
    assert_eq!(res_bytes[0], 0x89);
    assert_eq!(res_bytes[1], 0x50); 
    assert_eq!(res_bytes[2], 0x4E);
    assert_eq!(res_bytes[3], 0x47);
    
    // Optional: Save to disk for manual inspection
    // let mut file = File::create("output_e2e.png").unwrap();
    // file.write_all(&res_bytes).unwrap();
}
