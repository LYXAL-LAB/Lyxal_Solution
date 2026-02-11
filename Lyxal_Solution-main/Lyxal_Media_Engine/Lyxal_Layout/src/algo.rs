use crate::node::{LayoutNode, Display};
use crate::geometry::{Size, Rect};
use crate::measure::{measure, SizeConstraints};
use crate::flex::{layout_flex, FlexResult};
use crate::LyxalResult;

/// Intermediate result of layout pass
#[derive(Debug, Clone)]
pub struct LayoutResult<'a> {
    pub node: &'a crate::node::LayoutNode, // Reference to original node
    pub size: Size,
    pub children: Vec<(Rect, LayoutResult<'a>)>,
}

/// Computes the layout for a node tree given a set of constraints.
/// This function performs a recursive layout pass (Measure -> Layout -> Position).
/// 
/// # Arguments
/// * `node` - The root node of the tree (or subtree) to layout.
/// * `constraints` - The size constraints imposed by the parent (top-level usually Inf).
/// 
/// # Returns
/// A `LayoutResult` containing the calculated size and the position of distinct children.
pub fn compute_layout<'a>(node: &'a LayoutNode, constraints: SizeConstraints) -> LyxalResult<LayoutResult<'a>> {
    match node.style.display {
        Display::None => Ok(LayoutResult { node, size: Size::new(0.0, 0.0), children: vec![] }),
        Display::Flex => {
            let res = layout_flex_recursive(node, constraints)?;
            Ok(LayoutResult {
                node,
                size: res.content_size,
                children: zip_results(res.children_rects, node, constraints)?,
            })
        },
        Display::Grid => {
            let res = crate::grid::layout_grid(node, constraints)?;
             Ok(LayoutResult {
                node,
                size: res.content_size,
                children: zip_results(res.children_rects, node, constraints)?,
            })
        },
        Display::Block => {
             let size = measure(node, constraints)?;
             Ok(LayoutResult { node, size, children: vec![] })
        }
    }
}

// Helper to recurse into flex children
// The `layout_flex` function currently does a "shallow" measure of children.
fn layout_flex_recursive(node: &LayoutNode, constraints: SizeConstraints) -> LyxalResult<FlexResult> {
    layout_flex(node, constraints)
}

fn zip_results<'a>(rects: Vec<Rect>, node: &'a LayoutNode, _constraints: SizeConstraints) -> LyxalResult<Vec<(Rect, LayoutResult<'a>)>> {
    let mut results = Vec::new();
    for (i, rect) in rects.into_iter().enumerate() {
        if let Some(child_node) = node.children.get(i) {
             let child_constraints = SizeConstraints {
                 min: Size::new(rect.width, rect.height),
                 max: Size::new(rect.width, rect.height),
             };
             let child_res = compute_layout(child_node, child_constraints)?;
             results.push((rect, child_res));
        }
    }
    Ok(results)
}
