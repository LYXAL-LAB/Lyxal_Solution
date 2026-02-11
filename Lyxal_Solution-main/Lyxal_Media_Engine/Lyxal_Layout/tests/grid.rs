use Lyxal_Layout::{compute_layout, LayoutNode, NodeType, LayoutStyle, Dimension, GridTrack, Display, SizeConstraints, Size};

#[test]
fn test_grid_fixed_columns() {
    let mut grid = LayoutNode::new(NodeType::Box).with_id("grid");
    grid.style.display = Display::Grid;
    grid.style.grid_template_columns = vec![
        GridTrack::Points(100.0), 
        GridTrack::Points(100.0)
    ]; // 2 columns 100px
    grid.style.gap = 10.0;
    grid.style.padding = Lyxal_Layout::Edges::all(10.0);
    
    // Add 4 children
    for i in 0..4 {
        let child = LayoutNode::new(NodeType::Box).with_id(format!("c{}", i));
        // Intrinsic size 0, but grid stretches them? 
        // Or fixed height?
        // Let's give them fixed height to measure rows.
        // child is immutable in loop, wait.
        grid.children.push(child);
    }
    // Set heights
    grid.children[0].style.height = Dimension::Points(50.0);
    grid.children[1].style.height = Dimension::Points(50.0);
    grid.children[2].style.height = Dimension::Points(50.0);
    grid.children[3].style.height = Dimension::Points(50.0);
    
    let constraints = SizeConstraints::default();
    
    let res = compute_layout(&grid, constraints).unwrap();
    
    // Width = 10 padding + 100 + 10 gap + 100 + 10 padding = 230
    assert_eq!(res.size.width, 230.0);
    
    // Check positions (after recursive zip, they are in `children`)
    // Col 1, Row 1
    assert_eq!(res.children[0].0.x, 10.0);
    assert_eq!(res.children[0].0.y, 10.0);
    
    // Col 2, Row 1
    assert_eq!(res.children[1].0.x, 10.0 + 100.0 + 10.0); // 120
    assert_eq!(res.children[1].0.y, 10.0);
    
    // Col 1, Row 2
    assert_eq!(res.children[2].0.x, 10.0);
    assert_eq!(res.children[2].0.y, 10.0 + 50.0 + 10.0); // 70
}

#[test]
fn test_grid_fr_columns() {
    let mut grid = LayoutNode::new(NodeType::Box);
    grid.style.display = Display::Grid;
    grid.style.grid_template_columns = vec![
        GridTrack::Fr(1.0), 
        GridTrack::Fr(2.0)
    ]; // 1fr 2fr
    
    for _ in 0..2 {
        let mut child = LayoutNode::new(NodeType::Box);
        child.style.height = Dimension::Points(50.0);
        grid.children.push(child);
    }
    
    // Constrain container to 300px
    let mut constraints = SizeConstraints::default();
    constraints.max.width = 300.0;
    
    let res = compute_layout(&grid, constraints).unwrap();
    
    // Total FR = 3. Unit = 300 / 3 = 100.
    // Col 1 = 100. Col 2 = 200.
    assert_eq!(res.children[0].0.width, 100.0);
    assert_eq!(res.children[1].0.width, 200.0);
}

#[test]
fn test_grid_span() {
    let mut grid = LayoutNode::new(NodeType::Box);
    grid.style.display = Display::Grid;
    grid.style.grid_template_columns = vec![
        GridTrack::Points(50.0), 
        GridTrack::Points(50.0),
        GridTrack::Points(50.0)
    ]; // 3 cols
    grid.style.gap = 10.0;
    
    // Item 1: Span 2
    let mut c1 = LayoutNode::new(NodeType::Box);
    c1.style.column_span = 2;
    c1.style.height = Dimension::Points(50.0);
    
    // Item 2: Span 1 (Should be on same row, col 3)
    let mut c2 = LayoutNode::new(NodeType::Box);
    c2.style.height = Dimension::Points(50.0);
    
    grid.children.push(c1);
    grid.children.push(c2);
    
    let res = compute_layout(&grid, SizeConstraints::default()).unwrap();
    
    // Item 1 Width: 50 + 10 + 50 = 110
    assert_eq!(res.children[0].0.width, 110.0);
    
    // Item 2 Position: 110 + 10 (gap)? No. 
    // Grid positions:
    // Col 1 start = 0.
    // Col 2 start = 60.
    // Col 3 start = 120.
    // Item 2 is at Col 3.
    assert_eq!(res.children[1].0.x, 120.0);
}
