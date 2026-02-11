use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Display {
    None,
    Flex,
    Grid,
    Block, // Default container
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum PositionType {
    Relative,
    Absolute,
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum FlexDirection {
    Row,
    Column,
    // RowReverse, ColumnReverse: Not prioritized for V1
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum JustifyContent {
    Start,
    Center,
    End,
    SpaceBetween,
    SpaceAround,
    SpaceEvenly,
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum AlignItems {
    Start,
    Center,
    End,
    Stretch,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum GridTrack {
    Auto, // Not prioritizing for V1, but good to have
    Points(f32),
    Fr(f32),
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum FlexWrap {
    NoWrap,
    Wrap,
    // WrapReverse not in V1
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Overflow {
    Visible,
    Hidden,
    // Scroll/Auto not in V1
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case", tag = "kind", content = "value")]
pub enum NodeType {
    Box,
    Text,
    Image,
    Svg,
    Shape,
    Group,
    Custom(String),
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Dimension {
    Auto,
    Points(f32),
    /// Percent value strictly between 0.0 and 1.0 (e.g. 0.5 = 50%)
    Percent(f32),
}

impl Dimension {
    // Helper to validate percent
    pub fn new_percent(val: f32) -> Self {
        Dimension::Percent(val.clamp(0.0, 1.0))
    }
}

impl Default for Dimension {
    fn default() -> Self {
        Dimension::Auto
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Default, Serialize, Deserialize)]
pub struct Edges {
    pub top: f32,
    pub right: f32,
    pub bottom: f32,
    pub left: f32,
}

impl Edges {
    pub fn all(val: f32) -> Self {
        Self { top: val, right: val, bottom: val, left: val }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LayoutStyle {
    #[serde(default = "default_display")]
    pub display: Display,
    #[serde(default = "default_position")]
    pub position: PositionType,
    #[serde(default = "default_overflow")]
    pub overflow: Overflow,

    // Coordinates for Absolute Position
    #[serde(skip_serializing_if = "Option::is_none")]
    pub top: Option<f32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub right: Option<f32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bottom: Option<f32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub left: Option<f32>,

    // Flex Props
    #[serde(default = "default_flex_dir")]
    pub flex_direction: FlexDirection,
    #[serde(default = "default_flex_wrap")]
    pub flex_wrap: FlexWrap,
    #[serde(default = "default_justify")]
    pub justify_content: JustifyContent,
    #[serde(default = "default_align")]
    pub align_items: AlignItems,
    
    // Grid Props (V1)
    #[serde(default)]
    pub grid_template_columns: Vec<GridTrack>,
    #[serde(default = "default_col_span")]
    pub column_span: u32,
    
    #[serde(default)]
    pub flex_grow: f32,
    #[serde(default)]
    pub flex_shrink: f32,
    #[serde(default)] // Basis usually Auto
    pub flex_basis: Dimension,

    // Bounds
    #[serde(default)]
    pub width: Dimension,
    #[serde(default)]
    pub height: Dimension,
    #[serde(default)]
    pub min_width: Dimension,
    #[serde(default)]
    pub max_width: Dimension,
    #[serde(default)]
    pub min_height: Dimension,
    #[serde(default)]
    pub max_height: Dimension,
    
    // Aspect Ratio (> 0.0)
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub aspect_ratio: Option<f32>,

    // Spacing
    #[serde(default)]
    pub margin: Edges,
    #[serde(default)]
    pub padding: Edges,
    #[serde(default)]
    pub gap: f32,
}

// Defaults
fn default_display() -> Display { Display::Block }
fn default_position() -> PositionType { PositionType::Relative }
fn default_overflow() -> Overflow { Overflow::Visible }
fn default_flex_dir() -> FlexDirection { FlexDirection::Row }
fn default_flex_wrap() -> FlexWrap { FlexWrap::NoWrap }
fn default_justify() -> JustifyContent { JustifyContent::Start }
fn default_align() -> AlignItems { AlignItems::Stretch }
fn default_col_span() -> u32 { 1 }

impl Default for LayoutStyle {
    fn default() -> Self {
        Self {
            display: Display::Block,
            position: PositionType::Relative,
            overflow: Overflow::Visible,
            top: None, right: None, bottom: None, left: None,
            flex_direction: FlexDirection::Row,
            flex_wrap: FlexWrap::NoWrap,
            justify_content: JustifyContent::Start,
            align_items: AlignItems::Stretch,
            
            grid_template_columns: Vec::new(),
            column_span: 1,

            flex_grow: 0.0,
            flex_shrink: 1.0,
            flex_basis: Dimension::Auto,
            width: Dimension::Auto,
            height: Dimension::Auto,
            min_width: Dimension::Auto,
            max_width: Dimension::Auto,
            min_height: Dimension::Auto,
            max_height: Dimension::Auto,
            aspect_ratio: None,
            margin: Edges::default(),
            padding: Edges::default(),
            gap: 0.0,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LayoutNode {
    /// Optional ID. Only guaranteed unique if provided by caller.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub id: Option<String>,
    
    #[serde(rename = "type")]
    pub node_type: NodeType,
    
    #[serde(default)]
    pub style: LayoutStyle,
    #[serde(default)]
    pub children: Vec<LayoutNode>,
    
    // Optional content for simulation/measurement (e.g. text string)
    pub content: Option<String>,
}

impl LayoutNode {
    pub fn new(node_type: NodeType) -> Self {
        Self {
            id: None,
            node_type,
            style: LayoutStyle::default(),
            children: Vec::new(),
            content: None,
        }
    }
    
    pub fn with_id(mut self, id: impl Into<String>) -> Self {
        self.id = Some(id.into());
        self
    }
}
