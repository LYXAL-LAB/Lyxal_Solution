use crate::algo::LayoutResult;
use serde::Serialize;
use crate::node::NodeType;

#[derive(Debug, Serialize, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum SceneOverflow {
    Visible,
    Hidden,
}

#[derive(Debug, Serialize)]
pub struct SceneLayer {
    pub id: Option<String>,
    #[serde(rename = "type")]
    pub layer_type: String,
    pub x: f32,
    pub y: f32,
    pub width: f32,
    pub height: f32,
    // Other props (opacity, color) would be passed through from style/content (TODO)
    // For Layout Engine, we output primarily bounds.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub text: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub overflow: Option<SceneOverflow>,
}

#[derive(Debug, Serialize)]
pub struct Scene {
    pub width: f32,
    pub height: f32,
    pub layers: Vec<SceneLayer>,
}

pub fn resolve_to_scene(result: &LayoutResult, _root_id: Option<String>) -> Scene {
    let mut layers = Vec::new();
    
    // Assume root starts at 0,0
    flatten(result, 0.0, 0.0, &mut layers);
    
    Scene {
        width: result.size.width,
        height: result.size.height,
        layers,
    }
}

fn flatten(result: &LayoutResult, abs_x: f32, abs_y: f32, layers: &mut Vec<SceneLayer>) {
    // 1. Output the node itself (Background/Debug)
    // Map NodeType to string
    let type_str = match &result.node.node_type {
        NodeType::Box => "box",
        NodeType::Text => "text",
        NodeType::Image => "image",
        NodeType::Svg => "svg",
        NodeType::Shape => "shape",
        NodeType::Group => "group",
        NodeType::Custom(s) => s.as_str(),
    };
    
    let overflow_enum = match result.node.style.overflow {
        crate::node::Overflow::Visible => None,
        crate::node::Overflow::Hidden => Some(SceneOverflow::Hidden),
    };

    let layer = SceneLayer {
        id: result.node.id.clone(),
        layer_type: type_str.to_string(),
        x: abs_x,
        y: abs_y,
        width: result.size.width,
        height: result.size.height,
        text: result.node.content.clone(),
        overflow: overflow_enum,
    };
    
    layers.push(layer);
    
    // 2. Recurse children
    for (relative_rect, child_res) in &result.children {
        flatten(child_res, abs_x + relative_rect.x, abs_y + relative_rect.y, layers);
    }
}
