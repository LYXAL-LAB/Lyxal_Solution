use Lyxal_Layout::{layout_flex, SizeConstraints, LayoutNode, NodeType, LayoutStyle, Dimension, FlexDirection, JustifyContent, Size};

#[test]
fn test_flex_row_simple() {
    // Parent Row, 3 children fixed width 50
    let mut parent = LayoutNode::new(NodeType::Box);
    parent.style.flex_direction = FlexDirection::Row;
    
    for i in 0..3 {
        let mut child = LayoutNode::new(NodeType::Box).with_id(format!("child{}", i));
        child.style.width = Dimension::Points(50.0);
        child.style.height = Dimension::Points(50.0);
        parent.children.push(child);
    }
    
    let constraints = SizeConstraints { 
        min: Size::default(), 
        max: Size::new(500.0, 500.0) 
    };
    
    let result = layout_flex(&parent, constraints).unwrap();
    
    assert_eq!(result.children_rects.len(), 3);
    assert_eq!(result.children_rects[0].x, 0.0);
    assert_eq!(result.children_rects[1].x, 50.0);
    assert_eq!(result.children_rects[2].x, 100.0);
    assert_eq!(result.content_size.width, 150.0);
}

#[test]
fn test_flex_grow() {
    // Parent 300px wide. 2 Children grow=1.
    let mut parent = LayoutNode::new(NodeType::Box);
    parent.style.flex_direction = FlexDirection::Row;
    parent.style.width = Dimension::Percent(1.0);
    
    let mut c1 = LayoutNode::new(NodeType::Box);
    c1.style.flex_grow = 1.0;
    
    let mut c2 = LayoutNode::new(NodeType::Box);
    c2.style.flex_grow = 1.0;
    
    parent.children.push(c1);
    parent.children.push(c2);
    
    let constraints = SizeConstraints {
        min: Size::default(),
        max: Size::new(300.0, 100.0)
    };
    
    let result = layout_flex(&parent, constraints).unwrap();
    
    assert_eq!(result.children_rects[0].width, 150.0);
    assert_eq!(result.children_rects[1].width, 150.0);
}

#[test]
fn test_flex_justify_center() {
    let mut parent = LayoutNode::new(NodeType::Box);
    parent.style.justify_content = JustifyContent::Center;
    parent.style.width = Dimension::Percent(1.0);
    
    let mut child = LayoutNode::new(NodeType::Box);
    child.style.width = Dimension::Points(100.0);
    
    parent.children.push(child);
    
    // Parent 300px
    let constraints = SizeConstraints {
        min: Size::default(),
        max: Size::new(300.0, 100.0)
    };
    
    let result = layout_flex(&parent, constraints).unwrap();
    
    // (300 - 100) / 2 = 100 offset
    assert_eq!(result.children_rects[0].x, 100.0);
}
