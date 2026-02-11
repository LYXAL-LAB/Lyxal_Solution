use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum TextAlign {
    Left,
    Center,
    Right,
    Justify,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PositionedGlyph {
    pub glyph_id: u32, // ID from the font
    pub x: f32,
    pub y: f32,
    pub w: f32, 
    pub h: f32,
    pub rotation: f32, // Radians
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LineMetric {
    pub y: f32,
    pub height: f32,
    pub width: f32,
    pub start_index: usize,
    pub end_index: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TextLayout {
    pub width: f32,
    pub height: f32,
    pub lines: Vec<LineMetric>,
    pub glyphs: Vec<PositionedGlyph>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LayoutConfig {
    pub max_width: Option<f32>,
    pub align: TextAlign,
}

impl Default for LayoutConfig {
    fn default() -> Self {
        Self {
            max_width: None,
            align: TextAlign::Left,
        }
    }
}
