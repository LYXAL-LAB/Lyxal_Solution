use Lyxal_Layout::{measure, SizeConstraints, LayoutNode, NodeType};

#[test]
fn test_measure_text_box() {
    let mut node = LayoutNode::new(NodeType::Text);
    node.content = Some("Hello".to_string()); // 5 chars
    
    let constraints = SizeConstraints::default(); // Infinite
    let size = measure(&node, constraints).unwrap();
    
    // char_width = 10.0, len = 5 -> 50.0
    assert_eq!(size.width, 50.0);
    assert_eq!(size.height, 14.0);
}

#[test]
fn test_measure_image_aspect_ratio() {
    let mut node = LayoutNode::new(NodeType::Image);
    node.style.aspect_ratio = Some(2.0); // Width = 2 * Height
    
    // Test 1: Constrained Width to 200.0
    let mut constraints = SizeConstraints::default();
    constraints.max.width = 200.0;
    
    let size = measure(&node, constraints).unwrap();
    assert_eq!(size.width, 200.0);
    assert_eq!(size.height, 100.0);
    
    // Test 2: Constrained Height to 50.0
    let mut constraints2 = SizeConstraints::default();
    constraints2.max.height = 50.0;
    
    let size2 = measure(&node, constraints2).unwrap();
    assert_eq!(size2.height, 50.0);
    assert_eq!(size2.width, 100.0);
}

#[test]
fn test_measure_box_empty() {
    let node = LayoutNode::new(NodeType::Box);
    let constraints = SizeConstraints::default();
    let size = measure(&node, constraints).unwrap();
    assert_eq!(size.width, 0.0);
    assert_eq!(size.height, 0.0);
}
