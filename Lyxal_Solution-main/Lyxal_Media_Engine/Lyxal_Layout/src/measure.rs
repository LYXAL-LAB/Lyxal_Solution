use crate::node::{LayoutNode, NodeType};
use crate::geometry::Size;
use crate::{LyxalResult, LayoutError};

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct SizeConstraints {
    pub min: Size,
    pub max: Size,
}

impl Default for SizeConstraints {
    fn default() -> Self {
        Self {
            min: Size::new(0.0, 0.0),
            max: Size::new(f32::INFINITY, f32::INFINITY),
        }
    }
}



pub fn measure(node: &LayoutNode, constraints: SizeConstraints) -> LyxalResult<Size> {
    let raw_size = match node.node_type {
        NodeType::Text => measure_text(node, constraints),
        NodeType::Image => measure_image(node, constraints),
        NodeType::Box | NodeType::Group => Size::new(0.0, 0.0), // Containers usually size by children (handled in layout pass)
        NodeType::Svg | NodeType::Shape => measure_vector(node, constraints),
        NodeType::Custom(_) => Size::new(100.0, 100.0), // Placeholder
    };
    
    // Apply style min/max
    // Helper to resolve Value/Percent/Auto - duplicated from flex.rs (should be shared util)
    let resolve_val = |d: &crate::node::Dimension, parent: f32| -> Option<f32> {
        match d {
            crate::node::Dimension::Points(v) => Some(*v),
            crate::node::Dimension::Percent(p) => if parent.is_finite() { Some(parent * p) } else { None },
            crate::node::Dimension::Auto => None,
        }
    };
    
    let parent_w = constraints.max.width;
    let parent_h = constraints.max.height;
    
    let min_w = resolve_val(&node.style.min_width, parent_w).unwrap_or(0.0);
    // If max is Auto, it is Infinity.
    let max_w_val = resolve_val(&node.style.max_width, parent_w).unwrap_or(f32::INFINITY);

    let min_h = resolve_val(&node.style.min_height, parent_h).unwrap_or(0.0);
    let max_h_val = resolve_val(&node.style.max_height, parent_h).unwrap_or(f32::INFINITY);

    // Validation V2: Explicit Error if Min > Max
    if min_w > max_w_val {
        return Err(LayoutError::InvalidConstraints(format!("min_width ({}) > max_width ({}) for node {:?}", min_w, max_w_val, node.id)));
    }
    if min_h > max_h_val {
        return Err(LayoutError::InvalidConstraints(format!("min_height ({}) > max_height ({}) for node {:?}", min_h, max_h_val, node.id)));
    }
    
    // Apply External Constraints (e.g. from Parent Flex/Grid layout)
    // If min == max (Fixed), this forces size.
    Ok(Size::new(
        raw_size.width.clamp(min_w, max_w_val).clamp(constraints.min.width, constraints.max.width),
        raw_size.height.clamp(min_h, max_h_val).clamp(constraints.min.height, constraints.max.height)
    ))
}

fn measure_text(node: &LayoutNode, _constraints: SizeConstraints) -> Size {
    // V1 Simulation: Estimate size based on char count
    // In real world, we would need font metrics here. 
    // This function calculates "Intrinsic" size.
    if let Some(text) = &node.content {
        let char_width = 10.0; // Simulated font size
        let line_height = 14.0;
        let width = text.len() as f32 * char_width;
        let height = line_height;
        Size::new(width, height)
    } else {
        Size::new(0.0, 0.0)
    }
}

fn measure_image(node: &LayoutNode, constraints: SizeConstraints) -> Size {
    // If aspect ratio is known, use it to constrain dimensions
    if let Some(aspect_ratio) = node.style.aspect_ratio {
        // Try to respect constraints while keeping aspect ratio
        // If width is constrained (not infinite), calc height.
        // If height is constrained, calc width.
        
        if constraints.max.width.is_finite() {
            let width = constraints.max.width;
            let height = width / aspect_ratio;
            return Size::new(width, height);
        } else if constraints.max.height.is_finite() {
            let height = constraints.max.height;
            let width = height * aspect_ratio;
            return Size::new(width, height);
        }
        
        // Default if unconstrained
        Size::new(100.0, 100.0 / aspect_ratio)
    } else {
        // Default placeholder for image without aspect ratio
        Size::new(100.0, 100.0)
    }
}

fn measure_vector(_node: &LayoutNode, _constraints: SizeConstraints) -> Size {
    // Vectors usually have explicit size in style, or are 0x0 intrinsically
    Size::new(0.0, 0.0)
}
