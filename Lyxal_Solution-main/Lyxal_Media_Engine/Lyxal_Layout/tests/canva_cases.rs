use Lyxal_Layout::{
    LayoutNode, NodeType, LayoutStyle, Dimension, JustifyContent, AlignItems, 
    SizeConstraints, Size, compute_layout, resolve_to_scene, FlexDirection
};

#[test]
fn test_canva_button_scenario() {
    // Scenario:
    // Container (Button) - Auto Width? No, Flex Row with Text inside.
    // Children: Text "Click Me"
    
    let mut button = LayoutNode::new(NodeType::Box).with_id("btn");
    button.style.display = Lyxal_Layout::Display::Flex;
    button.style.flex_direction = FlexDirection::Row;
    button.style.padding = Lyxal_Layout::Edges::all(10.0);
    button.style.justify_content = JustifyContent::Center;
    button.style.align_items = AlignItems::Center;
    // button.style.width = Dimension::Auto; // Let it grow
    
    let mut text = LayoutNode::new(NodeType::Text).with_id("txt");
    text.content = Some("Click".to_string()); // 5 chars -> 50px width, 14px height
    
    button.children.push(text);
    
    // Layout
    let constraints = SizeConstraints {
        min: Size::new(0.0, 0.0),
        max: Size::new(500.0, 500.0),
    };
    
    let layout_res = compute_layout(&button, constraints).unwrap();
    
    // Scene
    let scene = resolve_to_scene(&layout_res, None);
    
    // Check Container Size
    // Text: 50x14
    // Padding: 10
    // Width = 50 + 10 + 10 = 70.0
    // Height = 14 + 10 + 10 = 34.0
    assert_eq!(layout_res.size.width, 70.0);
    assert_eq!(layout_res.size.height, 34.0);
    
    // Check Scene output
    assert_eq!(scene.layers.len(), 2); // Button + Text
    
    // Layer 0: Button
    assert_eq!(scene.layers[0].id, Some("btn".to_string()));
    assert_eq!(scene.layers[0].width, 70.0);
    
    // Layer 1: Text
    assert_eq!(scene.layers[1].id, Some("txt".to_string()));
    // Relative x was 10.0 (padding). Absolute x should be 0 + 10 = 10.
    assert_eq!(scene.layers[1].x, 10.0);
    assert_eq!(scene.layers[1].y, 10.0);
}
