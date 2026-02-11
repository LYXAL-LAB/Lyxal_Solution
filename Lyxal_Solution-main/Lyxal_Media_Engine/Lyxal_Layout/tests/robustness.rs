use Lyxal_Layout::{compute_layout, resolve_to_scene, LayoutNode, NodeType, SizeConstraints, Size, Dimension, FlexDirection, Overflow};

#[test]
fn test_min_max_conflict() {
    // Case: Min > Max. Min should win.
    let mut node = LayoutNode::new(NodeType::Box);
    node.style.min_width = Dimension::Points(100.0);
    node.style.max_width = Dimension::Points(50.0);
    
    // Intrinsic size 0. Flex loop should apply clamps.
    // Parent constraint loose.
    let constraints = SizeConstraints::default();
    let res = compute_layout(&node, constraints);
    
    // Expect Error (Min > Max)
    assert!(res.is_err());
    // Optional: Check error message matches "min_width > max_width"
}

#[test]
fn test_flex_grow_hits_max() {
    // Parent 300px.
    // Child: flex-grow 1, max-width 100px.
    // Expect: grow stops at 100. (Width = 100).
    
    let mut parent = LayoutNode::new(NodeType::Box);
    parent.style.display = Lyxal_Layout::Display::Flex;
    parent.style.flex_direction = FlexDirection::Row;
    parent.style.width = Dimension::Points(300.0);
    
    let mut child = LayoutNode::new(NodeType::Box);
    child.style.flex_grow = 1.0;
    child.style.max_width = Dimension::Points(100.0);
    
    parent.children.push(child);
    
    let constraints = SizeConstraints::default(); // parent fixed 300
    let res = compute_layout(&parent, constraints).unwrap();
    
    assert_eq!(res.children[0].1.size.width, 100.0);
}

#[test]
fn test_overflow_flag() {
    let mut node = LayoutNode::new(NodeType::Box);
    node.style.overflow = Overflow::Hidden;
    
    let res = compute_layout(&node, SizeConstraints::default()).unwrap();
    let scene = resolve_to_scene(&res, None);
    
    // We check via Serialize or Debug if SceneOverflow is not in scope easily?
    // Or add SceneOverflow to imports.
    // Assuming `use Lyxal_Layout::*;` brings SceneOverflow.
    
    // assert_eq!(scene.layers[0].overflow, Some(SceneOverflow::Hidden));
    // Since SceneOverflow is PartialEq.
    
    // Actually, SceneOverflow might not be imported if I used strict imports in test.
    // Let's check imports.
    
    // Re-check output.
    // If we can't import easily right now, verify verify serialization?
    // Or just import it.
    
    // Actually, simpler: verify via JSON string for robustness contract!
    let json = serde_json::to_string(&scene.layers[0]).unwrap();
    assert!(json.contains("\"overflow\":\"hidden\""));
}

#[test]
fn test_nested_percent_in_infinite() {
    // Parent: Auto width (Infinite constraint passed down as Inner Max W if constrained?)
    // If not constrained, Inner Max W is Info.
    // Child: Width 50%.
    // 50% of Inf = Inf? Or 0?
    // flex.rs resolve_min/max uses logic: if parent.is_finite() { parent * p } else { 0.0 or Inf }
    
    let mut parent = LayoutNode::new(NodeType::Box);
    parent.style.display = Lyxal_Layout::Display::Flex;
    // Auto width
    
    let mut child = LayoutNode::new(NodeType::Box);
    child.style.width = Dimension::Percent(0.5);
    
    parent.children.push(child);
    
    let constraints = SizeConstraints::default(); // Inf
    
    let res = compute_layout(&parent, constraints).unwrap();
    
    // 50% of Inf should resolve to 0.0 using current logic?
    // Let's verify.
    // If width is 0.0, it's fine. Main thing is no Panic (NaN/Inf propagation in a bad way).
    // Actually, `resolve_max` returns Inf.
    // `resolve_min` returns 0.0.
    // `size.clamp(0, Inf)` -> size=0.
    assert_eq!(res.children[0].1.size.width, 0.0);
}
