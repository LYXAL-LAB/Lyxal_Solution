use crate::timeline::Timeline;
use lyxal_layout::{LayoutNode, SizeConstraints, compute_layout, resolve_to_scene};
use lyxal_layout::geometry::Size; // Need Size
use lyxal_layout::Dimension; // Correct import
use lyxal_motion::{MotionTrack, MotionValue};
use lyxal_image::{ImageContext, LyxalImage, process};
use lyxal_adapter::adapt_scene;
use std::collections::HashMap;
use serde_json::{json, Value};
use lyxal_text::env::TextEnvironment;
use lyxal_font::FontRegistry;


pub struct SceneState {
    pub root: LayoutNode, 
    pub tracks: HashMap<String, Vec<MotionTrack>>,
}

pub struct Pipeline {
    pub timeline: Timeline,
    pub scene: SceneState,
    pub env: TextEnvironment,
}

impl Pipeline {
    pub fn new(timeline: Timeline, scene: SceneState) -> Self {
        // Init default empty environment for now.
        // In real app, this should be passed in or loaded from config.
        let registry = FontRegistry::new(None);
        let env = TextEnvironment::new(&registry).expect("Failed to init env");
        Self { timeline, scene, env }
    }

    pub fn render_frame(&mut self) -> Result<Vec<u8>, Box<dyn std::error::Error>> {
        let t = self.timeline.current_time();
        
        // 1. Motion Sampling (Layout Props)
        self.apply_motion(t);
        
        // 2. Layout Computing
        let width = self.timeline.config.width as f32;
        let height = self.timeline.config.height as f32;
        
        // Default constraints: fill canvas
        let constraints = SizeConstraints {
             min: Size::new(0.0, 0.0),
             max: Size::new(width, height),
        };
        
        // Map LayoutError to string or box error
        let computed = compute_layout(&self.scene.root, constraints)
            .map_err(|e| format!("Layout Error: {:?}", e))?;
            
        // resolve_to_scene takes (result, optional_root_id)
        let scene = resolve_to_scene(&computed, Some("root".to_string()));
        
        // 3. Adapter (Layout -> Layers)
        let mut layers = adapt_scene(&scene);
        
        // 4. Visual Overrides (Motion -> Visual Props)
        self.apply_visual_overrides(&mut layers, t);
        
        // 5. Render
        // Create base canvas
        let base_img = LyxalImage::new_empty(self.timeline.config.width, self.timeline.config.height);
        let base_bytes = base_img.to_bytes(image::ImageFormat::Png)?;
        
        let ctx = ImageContext::default();
        let payload = json!({ "layers": layers }).to_string();
        
        let result_bytes = process(&base_bytes, &payload, ctx, Some(&self.env))?;
        Ok(result_bytes)
    }
    
    pub fn apply_motion(&mut self, t: f32) {
        Self::apply_to_node(&mut self.scene.root, &self.scene.tracks, t);
    }
    
    fn apply_to_node(node: &mut LayoutNode, tracks_map: &HashMap<String, Vec<MotionTrack>>, t: f32) {
         if let Some(node_id) = &node.id {
             if let Some(tracks) = tracks_map.get(node_id) {
                 for track in tracks {
                     if let Some(val) = track.get_value(t) {
                         match track.property.as_str() {
                             "width" => if let MotionValue::Scalar(v) = val { 
                                 node.style.width = Dimension::Points(v); 
                             },
                             "height" => if let MotionValue::Scalar(v) = val {
                                 node.style.height = Dimension::Points(v);
                             },
                             // Can expand to Margin, Padding, Flex props here
                             _ => {}
                         }
                     }
                 }
             }
         }
         
         for child in &mut node.children {
             Self::apply_to_node(child, tracks_map, t);
         }
    }
    
    fn apply_visual_overrides(&self, layers: &mut Vec<lyxal_image::pipeline::LayerConfig>, t: f32) {
        for layer in layers.iter_mut() {
            // LayerConfig.id is Option<String>.
            if let Some(layer_id) = &layer.id {
                if let Some(tracks) = self.scene.tracks.get(layer_id) {
                    for track in tracks {
                        if let Some(val) = track.get_value(t) {
                            match track.property.as_str() {
                                "opacity" => {
                                    if let MotionValue::Scalar(v) = val {
                                        layer.opacity = Some(v);
                                    }
                                },
                                "color" | "fill" => {
                                    if let MotionValue::Color(r,g,b,_) = val {
                                         // Hex formatting #RRGGBB
                                         let hex = format!("#{:02X}{:02X}{:02X}", r, g, b);
                                         if let Some(Value::Object(map)) = &mut layer.params {
                                             if map.contains_key("fill") {
                                                 map.insert("fill".to_string(), json!(hex));
                                             }
                                             if map.contains_key("stroke") { 
                                                 map.insert("stroke".to_string(), json!(hex));
                                             }
                                         }
                                    }
                                }
                                _ => {}
                            }
                        }
                    }
                }
            }
        }
    }
}
