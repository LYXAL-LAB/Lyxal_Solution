use crate::core::LyxalImage;
use crate::context::ImageContext;
use crate::error::LyxalResult;
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
#[serde(tag = "action", rename_all = "snake_case")]
pub enum PipelineStep {
    Resize { w: u32, h: u32 },
    Crop { x: u32, y: u32, w: u32, h: u32 },
    Blur { sigma: f32 },
    Grayscale,
    Text { text: String, x: i32, y: i32, size: f32, color: String },
    WatermarkSvg { svg: String, x: i32, y: i32, scale: f32 },
    EmbedSecret { secret: String },
    
    // Bloc 1: Ajustements Photo
    Brightness { value: f32 },
    Contrast { value: f32 },
    Saturation { value: f32 },
    Temperature { value: f32 },
    Tint { value: f32 },
    Shadows { value: f32 },
    Highlights { value: f32 },
    Sharpness { value: f32 },
    Vignette { value: f32 },
    Sepia { value: f32 },
    
    // Bloc 3: Effets Artistiques
    Pixelate { size: u32 },
    Posterize { levels: u8 },
    Noise { intensity: f32 },
    Duotone { color1: String, color2: String },
    GlitchHorizontal,
    GlitchVertical,
    
    // Bloc 4: Shapes
    ShapeRect { x: f32, y: f32, width: f32, height: f32, fill: Option<String>, stroke: Option<String>, stroke_width: Option<f32> },
    ShapeCircle { cx: f32, cy: f32, radius: f32, fill: Option<String>, stroke: Option<String>, stroke_width: Option<f32> },
    ShapeLine { x1: f32, y1: f32, x2: f32, y2: f32, stroke: String, stroke_width: f32 },
    ShapeArrow { x1: f32, y1: f32, x2: f32, y2: f32, stroke: String, stroke_width: f32, head_size: f32 },
    ShapePolygon { points: Vec<(f32, f32)>, fill: Option<String>, stroke: Option<String>, stroke_width: Option<f32> },
    
    // Bloc 2: Blend Modes
    Blend { mode: String, color: String },
}

#[derive(Deserialize, Serialize)]
#[serde(tag = "op", rename_all = "snake_case")]
pub enum TransformOp {
    Translate { x: f32, y: f32 },
    Rotate { angle: f32 }, // Degrees
    Scale { kx: f32, ky: f32 },
    Skew { kx: f32, ky: f32 },
}

#[derive(Deserialize, Serialize)]
pub struct MaskConfig {
    #[serde(rename = "type")]
    pub type_: String, // "alpha", "luma", "clip"
    pub source: String, // Layer ID
}

// Bloc Chantier D: Gradients
#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct GradientStop {
    pub offset: f32,
    pub color: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum FillStyle {
    Solid { color: String },
    LinearGradient {
        start: (f32, f32), // Normalized 0..1
        end: (f32, f32),
        stops: Vec<GradientStop>,
    },
    RadialGradient {
        center: (f32, f32),
        radius: f32,
        stops: Vec<GradientStop>,
    }
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Effect {
    DropShadow { offset_x: f32, offset_y: f32, blur: f32, color: String, opacity: f32 },
    InnerShadow { offset_x: f32, offset_y: f32, blur: f32, color: String, opacity: f32 },
    Glow { blur: f32, color: String, opacity: f32, inner: Option<bool> },
    Outline { width: f32, color: String, position: Option<String> },
}

// Helper to parse fill inputs (String or Object)
pub fn parse_fill(v: &serde_json::Value) -> Option<FillStyle> {
    if let Some(s) = v.as_str() {
        return Some(FillStyle::Solid { color: s.to_string() });
    }
    serde_json::from_value(v.clone()).ok()
}

// Bloc Chantier C: Texte Pro Structs
#[derive(Deserialize, Serialize, Clone)]
pub struct FontConfig {
    pub family: String,
    pub size: f32,
    pub weight: Option<u16>, // 400 = Normal, 700 = Bold
    pub letter_spacing: Option<f32>, // px
    pub line_height: Option<f32>, // Multiplier (e.g. 1.2)
}

#[derive(Deserialize, Serialize, Clone)]
pub struct TextAlign {
    pub h: Option<String>, // "left", "center", "right", "justify"
    pub v: Option<String>, // "top", "middle", "bottom"
}

#[derive(Deserialize, Serialize, Clone)]
pub struct TextStroke {
    pub color: String,
    pub width: f32,
}

#[derive(Deserialize, Serialize, Clone)]
pub struct TextBox {
    pub width: f32,
    pub height: f32,
}

#[derive(Deserialize, Serialize)]
pub struct LayerConfig {
    pub id: Option<String>, // Bloc 5 Chunk B: Identification unique
    #[serde(rename = "type")]
    pub type_: String, // "image", "shape_rect", etc.
    pub params: Option<serde_json::Value>,
    pub opacity: Option<f32>, // Default 1.0
    pub blend: Option<String>, // Default "normal"
    pub visible: Option<bool>, // Default true
    pub transform: Option<Vec<TransformOp>>, // Bloc 5 Chunk A
    pub anchor: Option<String>, // "center", "top-left"
    pub mask: Option<MaskConfig>, // Bloc 5 Chunk B
    pub effects: Option<Vec<Effect>>, // Chantier E
}

#[derive(Deserialize)]
pub struct PipelineRequest {
    #[serde(default)] // Allow missing "steps" field (default to empty vec)
    pub steps: Vec<PipelineStep>,
    pub layers: Option<Vec<LayerConfig>>, 
}

pub fn process(image_bytes: &[u8], request_json: &str, ctx: ImageContext, env: Option<&lyxal_text::env::TextEnvironment>) -> LyxalResult<Vec<u8>> {
    let req: PipelineRequest = serde_json::from_str(request_json)
        .map_err(|e| crate::error::LyxalError::InvalidParam(e.to_string()))?;

    if req.steps.len() > ctx.max_steps {
        return Err(crate::error::LyxalError::QuotaExceeded("Too many steps".into()));
    }

    let mut img = LyxalImage::from_bytes(image_bytes, &ctx)?;

    for step in req.steps {
        match step {
            PipelineStep::Resize { w, h } => {
                if w == 0 || h == 0 || w > ctx.max_width || h > ctx.max_height {
                    return Err(crate::error::LyxalError::InvalidParam(format!(
                        "Resize invalid: {}x{} (Max {}x{})", w, h, ctx.max_width, ctx.max_height
                    )));
                }
                img.resize(w, h)?
            },
            PipelineStep::Crop { x, y, w, h } => {
                 if w == 0 || h == 0 {
                    return Err(crate::error::LyxalError::InvalidParam("Crop dimension 0".into()));
                 }
                 // On laisse crop_imm gérer le clamping, mais on rejette les tailles nulles
                 img.crop(x, y, w, h)?
            },
            PipelineStep::Blur { sigma } => {
                if sigma <= 0.0 || sigma > 100.0 || !sigma.is_finite() {
                    return Err(crate::error::LyxalError::InvalidParam("Blur sigma must be 0.0-100.0".into()));
                }
                img.blur(sigma)?
            },
            PipelineStep::Grayscale => img.grayscale()?,
            PipelineStep::Text { text, x, y, size, color } => {
                if text.is_empty() { return Err(crate::error::LyxalError::InvalidParam("Text empty".into())); }
                if size <= 0.0 || size > 500.0 { return Err(crate::error::LyxalError::InvalidParam("Text size invalid".into())); }
                img.add_rich_text(&text, x, y, size, &color, env)?
            },
            PipelineStep::WatermarkSvg { svg, x, y, scale } => {
                if svg.is_empty() { return Err(crate::error::LyxalError::InvalidParam("SVG empty".into())); }
                if scale <= 0.0 || scale > 100.0 { return Err(crate::error::LyxalError::InvalidParam("SVG scale invalid".into())); }
                img.overlay_svg(&svg, x, y, scale)?
            },
            PipelineStep::EmbedSecret { secret } => {
                if secret.is_empty() { return Err(crate::error::LyxalError::InvalidParam("Secret empty".into())); }
                if secret.len() > 1024 { return Err(crate::error::LyxalError::InvalidParam("Secret too long".into())); }
                img.embed_secret(&secret)?
            },
            
            // --- Bloc 1 Impl ---
            PipelineStep::Brightness { value } => {
                if value < -1.0 || value > 1.0 { return Err(crate::error::LyxalError::InvalidParam("Brightness must be [-1.0, 1.0]".into())); }
                img.brightness(value)?
            },
            PipelineStep::Contrast { value } => {
                if value < -1.0 || value > 1.0 { return Err(crate::error::LyxalError::InvalidParam("Contrast must be [-1.0, 1.0]".into())); }
                img.contrast(value)?
            },
            PipelineStep::Saturation { value } => {
                 if value < -1.0 || value > 3.0 { return Err(crate::error::LyxalError::InvalidParam("Saturation must be [-1.0, 3.0]".into())); }
                 img.saturation(value)?
            },
            PipelineStep::Temperature { value } => {
                if value < -1.0 || value > 1.0 { return Err(crate::error::LyxalError::InvalidParam("Temperature must be [-1.0, 1.0]".into())); }
                img.temperature(value)?
            },
             PipelineStep::Tint { value } => {
                if value < -1.0 || value > 1.0 { return Err(crate::error::LyxalError::InvalidParam("Tint must be [-1.0, 1.0]".into())); }
                img.tint(value)?
            },
            PipelineStep::Shadows { value } => {
                if value < 0.0 || value > 1.0 { return Err(crate::error::LyxalError::InvalidParam("Shadows must be [0.0, 1.0]".into())); }
                img.shadows(value)?
            },
            PipelineStep::Highlights { value } => {
                if value < 0.0 || value > 1.0 { return Err(crate::error::LyxalError::InvalidParam("Highlights must be [0.0, 1.0]".into())); }
                img.highlights(value)?
            },
            PipelineStep::Sharpness { value } => {
                if value < 0.0 || value > 5.0 { return Err(crate::error::LyxalError::InvalidParam("Sharpness must be [0.0, 5.0]".into())); }
                img.sharpness(value)?
            },
            PipelineStep::Vignette { value } => {
                if value < 0.0 || value > 1.0 { return Err(crate::error::LyxalError::InvalidParam("Vignette must be [0.0, 1.0]".into())); }
                img.vignette(value)?
            },
            PipelineStep::Sepia { value } => {
                if value < 0.0 || value > 1.0 { return Err(crate::error::LyxalError::InvalidParam("Sepia must be [0.0, 1.0]".into())); }
                img.sepia(value)?
            },
            
            // --- Bloc 3 Impl ---
            PipelineStep::Pixelate { size } => {
                if size <= 1 { return Err(crate::error::LyxalError::InvalidParam("Pixelate size must be > 1".into())); }
                img.pixelate(size)?
            },
            PipelineStep::Posterize { levels } => {
                if levels < 2 || levels > 16 { return Err(crate::error::LyxalError::InvalidParam("Posterize levels must be [2, 16]".into())); }
                img.posterize(levels)?
            },
            PipelineStep::Noise { intensity } => {
                if intensity < 0.0 || intensity > 1.0 { return Err(crate::error::LyxalError::InvalidParam("Noise intensity must be [0.0, 1.0]".into())); }
                 img.noise(intensity)?
            },
            PipelineStep::Duotone { color1, color2 } => {
                // Validation simple longueur hex
                if color1.len() != 7 || !color1.starts_with('#') { return Err(crate::error::LyxalError::InvalidParam("Duotone color1 must be #RRGGBB".into())); }
                if color2.len() != 7 || !color2.starts_with('#') { return Err(crate::error::LyxalError::InvalidParam("Duotone color2 must be #RRGGBB".into())); }
                img.duotone(&color1, &color2)?
            },
            PipelineStep::GlitchHorizontal => img.glitch_horizontal()?,
            PipelineStep::GlitchVertical => img.glitch_vertical()?,
            
            // --- Bloc 4 Impl ---
            PipelineStep::ShapeRect { x, y, width, height, fill, stroke, stroke_width } => {
                if width <= 0.0 || height <= 0.0 { return Err(crate::error::LyxalError::InvalidParam("Rect dims must be > 0".into())); }
                if let Some(w) = stroke_width { if w <= 0.0 { return Err(crate::error::LyxalError::InvalidParam("Stroke width must be > 0".into())); } }
                
                let fill_style = fill.as_ref().map(|c| FillStyle::Solid { color: c.clone() });
                let stroke_style = stroke.as_ref().map(|c| FillStyle::Solid { color: c.clone() });
                
                img.shape_rect(x, y, width, height, fill_style.as_ref(), stroke_style.as_ref(), stroke_width.unwrap_or(0.0), None)?
            },
            PipelineStep::ShapeCircle { cx, cy, radius, fill, stroke, stroke_width } => {
                if radius <= 0.0 { return Err(crate::error::LyxalError::InvalidParam("Radius must be > 0".into())); }
                if let Some(w) = stroke_width { if w <= 0.0 { return Err(crate::error::LyxalError::InvalidParam("Stroke width must be > 0".into())); } }
                
                let fill_style = fill.as_ref().map(|c| FillStyle::Solid { color: c.clone() });
                let stroke_style = stroke.as_ref().map(|c| FillStyle::Solid { color: c.clone() });

                img.shape_circle(cx, cy, radius, fill_style.as_ref(), stroke_style.as_ref(), stroke_width.unwrap_or(0.0), None)?
            },
            PipelineStep::ShapeLine { x1, y1, x2, y2, stroke, stroke_width } => {
                if stroke_width <= 0.0 { return Err(crate::error::LyxalError::InvalidParam("Stroke width must be > 0".into())); }
                 if stroke.len() != 7 || !stroke.starts_with('#') { return Err(crate::error::LyxalError::InvalidParam("Stroke must be #RRGGBB".into())); }
                img.shape_line(x1, y1, x2, y2, &stroke, stroke_width, None)?
            },
            PipelineStep::ShapeArrow { x1, y1, x2, y2, stroke, stroke_width, head_size } => {
                if stroke_width <= 0.0 { return Err(crate::error::LyxalError::InvalidParam("Stroke width must be > 0".into())); }
                if head_size <= 0.0 { return Err(crate::error::LyxalError::InvalidParam("Head size must be > 0".into())); }
                if stroke.len() != 7 || !stroke.starts_with('#') { return Err(crate::error::LyxalError::InvalidParam("Stroke must be #RRGGBB".into())); }
                img.shape_arrow(x1, y1, x2, y2, &stroke, stroke_width, head_size, None)?
            },
             PipelineStep::ShapePolygon { points, fill, stroke, stroke_width } => {
                if points.len() < 3 { return Err(crate::error::LyxalError::InvalidParam("Polygon needs >= 3 points".into())); }
                 if let Some(w) = stroke_width { if w <= 0.0 { return Err(crate::error::LyxalError::InvalidParam("Stroke width must be > 0".into())); } }
                 
                 let fill_style = fill.as_ref().map(|c| FillStyle::Solid { color: c.clone() });
                 let stroke_style = stroke.as_ref().map(|c| FillStyle::Solid { color: c.clone() });

                img.shape_polygon(points, fill_style.as_ref(), stroke_style.as_ref(), stroke_width.unwrap_or(0.0), None)?
            },
            
            // --- Bloc 2 Impl ---
            PipelineStep::Blend { mode, color } => {
                if color.len() != 7 || !color.starts_with('#') { return Err(crate::error::LyxalError::InvalidParam("Blend color must be #RRGGBB".into())); }
                img.data_blend(&mode, &color)?
            },
        }
    }

    // --- Bloc 5 Impl: Layer Composition ---
    if let Some(layers) = req.layers {
        
        // Master buffer (initially the base image or blank if first layer is not base?)
        // Usually, the input 'img' is layer 0 ("image").
        // But if layers are defined, they override steps.
        
        // Let's create a blank master buffer of same size as 'img' (which holds the base input)
        // Actually, if the first layer is "image", it should copy 'img'.
        
        // Strategy: 
        // 1. Create 'Master' RgbaImage.
        // 2. Iterate layers.
        // 3. For each layer:
        //    a. Create 'Layer' RgbaImage (transparent).
        //    b. Render content into 'Layer'.
        //    c. Blend 'Layer' onto 'Master'.
        
        let (width, height) = img.get_dimensions();
        let mut master = image::RgbaImage::new(width, height);
        
        // Store layer outputs for masking (ID -> RgbaImage)
        let mut layer_outputs: std::collections::HashMap<String, image::RgbaImage> = std::collections::HashMap::new();
        
        // If no layers provided, we might want to default to something, but here we iterate.
        for layer in layers {
            // NOTE: We do NOT skip invisible layers here, because they might be needed as mask sources.
            // We only skip blending them onto master later.
            
            // Create separate buffer for this layer to render into
            let mut layer_img = LyxalImage::new_empty(width, height);
            
            // Apply Transform if present
            
            // Helper: Build transform matrix rotating/scaling around a Pivot Point (Absolute)
            fn build_transform(ops: &[TransformOp], pivot: (f32, f32)) -> tiny_skia::Transform {
                let (px, py) = pivot;
                let mut m = tiny_skia::Transform::identity();
                
                // 1. Move Pivot to Origin
                m = m.post_translate(-px, -py);
                
                // 2. Apply Ops
                for op in ops {
                   match op {
                       TransformOp::Translate { x, y } => m = m.post_translate(*x, *y),
                       TransformOp::Rotate { angle } => m = m.post_rotate(*angle),
                       TransformOp::Scale { kx, ky } => m = m.post_scale(*kx, *ky),
                       _ => {}
                   }
                }
                
                // 3. Move Origin back to Pivot
                m = m.post_translate(px, py);
                
                m
            }
            
            // Helper: Compute Pivot based on Anchor and BBox
            fn get_pivot(anchor: Option<&str>, x: f32, y: f32, w: f32, h: f32) -> (f32, f32) {
                match anchor.unwrap_or("top-left") {
                    "center" => (x + w / 2.0, y + h / 2.0),
                    "top-left" | _ => (x, y),
                    // Could add "bottom-right" etc.
                }
            }

            match layer.type_.as_str() {
                "image" => {
                    if let Some(trans_ops) = &layer.transform {
                        let (w, h) = img.get_dimensions();
                        // Image layer is at 0,0
                        let pivot = get_pivot(layer.anchor.as_deref(), 0.0, 0.0, w as f32, h as f32);
                        let ts = build_transform(trans_ops, pivot);
                        
                        let src_img = img.clone();
                        layer_img.draw_image_transformed(&src_img, ts)?;
                    } else {
                        layer_img = img.clone(); 
                    }
                },
                "shape_rect" => {
                   if let Some(p) = layer.params {
                        let x = p.get("x").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let y = p.get("y").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let w = p.get("width").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let h = p.get("height").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        
                        let fill = p.get("fill").and_then(parse_fill);
                        // Stroke: For now support Gradient on stroke? CTO said "strokes advanced".
                        // Assuming parse_fill works for stroke too if JSON structure matches Solid/Gradient.
                        let stroke = p.get("stroke").and_then(parse_fill);
                        let stroke_width = p.get("stroke_width").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        
                        let ts = layer.transform.as_ref().map(|ops| {
                            let pivot = get_pivot(layer.anchor.as_deref(), x, y, w, h);
                            build_transform(ops, pivot)
                        });
                        layer_img.shape_rect(x, y, w, h, fill.as_ref(), stroke.as_ref(), stroke_width, ts)?;
                   }
                },
                "shape_circle" => {
                    if let Some(p) = layer.params {
                        let cx = p.get("cx").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let cy = p.get("cy").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let r = p.get("radius").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        
                        let fill = p.get("fill").and_then(parse_fill);
                        let stroke = p.get("stroke").and_then(parse_fill);
                        let stroke_width = p.get("stroke_width").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        
                        let ts = layer.transform.as_ref().map(|ops| {
                            // BBox of circle: cx-r, cy-r, 2r, 2r
                            let pivot = get_pivot(layer.anchor.as_deref(), cx - r, cy - r, r * 2.0, r * 2.0);
                            build_transform(ops, pivot)
                        });
                        layer_img.shape_circle(cx, cy, r, fill.as_ref(), stroke.as_ref(), stroke_width, ts)?;
                    }
                },
                 "shape_arrow" => {
                    if let Some(p) = layer.params {
                        let x1 = p.get("x1").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let y1 = p.get("y1").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let x2 = p.get("x2").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let y2 = p.get("y2").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let s = p.get("stroke").and_then(|v| v.as_str()).unwrap_or("#000000"); // Valid hex needed
                        let sw = p.get("stroke_width").and_then(|v| v.as_f64()).unwrap_or(1.0) as f32;
                        let hs = p.get("head_size").and_then(|v| v.as_f64()).unwrap_or(10.0) as f32;
                        
                         let ts = layer.transform.as_ref().map(|ops| {
                             // BBox for arrow? Roughly min/max.
                             let min_x = x1.min(x2);
                             let min_y = y1.min(y2);
                             let w = (x2-x1).abs();
                             let h = (y2-y1).abs();
                             let pivot = get_pivot(layer.anchor.as_deref(), min_x, min_y, w, h);
                             build_transform(ops, pivot)
                         });
                        layer_img.shape_arrow(x1, y1, x2, y2, s, sw, hs, ts)?;
                    }
                 },
                 "shape_line" => {
                     if let Some(p) = layer.params {
                        let x1 = p.get("x1").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let y1 = p.get("y1").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let x2 = p.get("x2").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let y2 = p.get("y2").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let s = p.get("stroke").and_then(|v| v.as_str()).unwrap_or("#000000");
                        let sw = p.get("stroke_width").and_then(|v| v.as_f64()).unwrap_or(1.0) as f32;
                        
                        let ts = layer.transform.as_ref().map(|ops| {
                             let min_x = x1.min(x2);
                             let min_y = y1.min(y2);
                             let w = (x2-x1).abs();
                             let h = (y2-y1).abs();
                             let pivot = get_pivot(layer.anchor.as_deref(), min_x, min_y, w, h);
                             build_transform(ops, pivot)
                        });
                        layer_img.shape_line(x1, y1, x2, y2, s, sw, ts)?;
                     }
                 },
                "shape_polygon" => {
                    if let Some(p) = layer.params {
                         let points_val = p.get("points").and_then(|v| v.as_array());
                         if let Some(pts_arr) = points_val {
                             let mut points = Vec::new();
                             for pt in pts_arr {
                                 if let Some(coords) = pt.as_array() {
                                     if coords.len() >= 2 {
                                         let x = coords[0].as_f64().unwrap_or(0.0) as f32;
                                         let y = coords[1].as_f64().unwrap_or(0.0) as f32;
                                         points.push((x, y));
                                     }
                                 }
                             }
                             
                             let fill = p.get("fill").and_then(parse_fill);
                             let stroke = p.get("stroke").and_then(parse_fill);
                             let stroke_width = p.get("stroke_width").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                             
                             let ts = layer.transform.as_ref().map(|ops| {
                                 // BBox of poly
                                 let min_x = points.iter().map(|p| p.0).fold(f32::INFINITY, f32::min);
                                 let max_x = points.iter().map(|p| p.0).fold(f32::NEG_INFINITY, f32::max);
                                 let min_y = points.iter().map(|p| p.1).fold(f32::INFINITY, f32::min);
                                 let max_y = points.iter().map(|p| p.1).fold(f32::NEG_INFINITY, f32::max);
                                 let w = max_x - min_x;
                                 let h = max_y - min_y;
                                 
                                 let pivot = get_pivot(layer.anchor.as_deref(), min_x, min_y, w, h);
                                 build_transform(ops, pivot)
                             });
                             layer_img.shape_polygon(points, fill.as_ref(), stroke.as_ref(), stroke_width, ts)?;
                         }
                    }
                },
                "text" => {
                    if let Some(p) = layer.params {
                        // Extract Text Layer Params
                        let text = p.get("text").and_then(|v| v.as_str()).unwrap_or("");
                        // Box (Required or default)
                        let box_data = p.get("box");
                        let w = box_data.and_then(|v| v.get("width")).and_then(|v| v.as_f64()).unwrap_or(width as f64).max(1.0) as f32; // Default full width
                        let h = box_data.and_then(|v| v.get("height")).and_then(|v| v.as_f64()).unwrap_or(height as f64).max(1.0) as f32; // Default full height
                        
                        // Extract positional X,Y (Default 0,0) - Actually Box position is implicit?
                        // Usually Box position is separate from dimensions.
                        // Let's assume params "x" and "y" also exist for text layer placement.
                        let x = p.get("x").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        let y = p.get("y").and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;
                        
                        // Font Config
                        let mut font_cfg = FontConfig { 
                            family: "Sans Serif".to_string(), 
                            size: 24.0, 
                            weight: None, 
                            letter_spacing: None, 
                            line_height: None 
                        };
                        if let Some(f) = p.get("font") {
                            font_cfg.family = f.get("family").and_then(|v| v.as_str()).unwrap_or("Sans Serif").to_string();
                            font_cfg.size = f.get("size").and_then(|v| v.as_f64()).unwrap_or(24.0) as f32;
                            font_cfg.weight = f.get("weight").and_then(|v| v.as_u64()).map(|v| v as u16);
                            font_cfg.letter_spacing = f.get("letter_spacing").and_then(|v| v.as_f64()).map(|v| v as f32);
                            font_cfg.line_height = f.get("line_height").and_then(|v| v.as_f64()).map(|v| v as f32);
                        }
                        
                        // Align
                        let mut align_cfg = TextAlign { h: None, v: None };
                        if let Some(a) = p.get("align") {
                            align_cfg.h = a.get("h").and_then(|v| v.as_str()).map(|s| s.to_string());
                            align_cfg.v = a.get("v").and_then(|v| v.as_str()).map(|s| s.to_string());
                        }
                        
                        // Style
                        let fill = p.get("fill").and_then(parse_fill);
                        let stroke_val = p.get("stroke");
                        let stroke = stroke_val.and_then(parse_fill);
                        let stroke_width = stroke_val.and_then(|v| v.get("width")).and_then(|v| v.as_f64()).unwrap_or(0.0) as f32;

                        // Transform
                        let ts = layer.transform.as_ref().map(|ops| {
                             let pivot = get_pivot(layer.anchor.as_deref(), x, y, w, h);
                             build_transform(ops, pivot)
                        });
                        
                        // Render
                        layer_img.draw_text_box(text, x, y, w, h, &font_cfg, &align_cfg, fill.as_ref(), stroke.as_ref(), stroke_width, ts, env)?;
                    }
                },
                 _ => {} // Unknown layer type, skip or warning
            }

            // --- Apply Effects (NEW) ---
            if let Some(effects) = &layer.effects {
                crate::effects::apply_effects(&mut layer_img, effects)?;
            }
            
            // Get raw buffer for masking and blending
            let mut layer_rgba = layer_img.to_rgba8_cloned(); 
            
            // --- MASK LOGIC ---
            if let Some(mask_cfg) = &layer.mask {
                let mask_source = layer_outputs.get(&mask_cfg.source)
                    .ok_or(crate::error::LyxalError::InvalidParam(format!("Mask source '{}' not found", mask_cfg.source)))?;
                
                // Dimensions must match
                if mask_source.width() != width || mask_source.height() != height {
                     return Err(crate::error::LyxalError::InvalidParam("Mask dimensions mismatch".into()));
                }
                
                // Validate Mask Type
                let is_luma = match mask_cfg.type_.as_str() {
                    "luma" => true,
                    "alpha" | "clip" => false, 
                    _ => return Err(crate::error::LyxalError::InvalidParam("Invalid mask type".into())),
                };

                // Apply Mask
                for (x, y, pixel) in layer_rgba.enumerate_pixels_mut() {
                    let mask_pixel = mask_source.get_pixel(x, y);
                    let mask_alpha = if is_luma {
                        // Luma: 0.2126*r + 0.7152*g + 0.0722*b
                        // Input is u8, normalize to 0..1 then *255
                        let lum = 0.2126 * mask_pixel[0] as f32 + 0.7152 * mask_pixel[1] as f32 + 0.0722 * mask_pixel[2] as f32;
                        // Multiply by source alpha? Usually just Luminance determines opacity.
                        // Standard Luma Mask: White=Opaque, Black=Transparent.
                        lum / 255.0
                    } else {
                        // Alpha / Clip: Use source Alpha
                        mask_pixel[3] as f32 / 255.0
                    };
                    
                    // Multiply current alpha by mask alpha
                    let new_alpha = (pixel[3] as f32 * mask_alpha) as u8;
                    pixel[3] = new_alpha;
                }
            }

            // Store current layer state if ID is present (for future masks)
            if let Some(id) = &layer.id {
                layer_outputs.insert(id.clone(), layer_rgba.clone());
            }

            // Composition onto Master
            // Blend layer_img onto master with opacity & mode
            
            if layer.visible.unwrap_or(true) {
                let opacity = layer.opacity.unwrap_or(1.0);
                let mode = layer.blend.as_deref().unwrap_or("normal");
                
                for (x, y, pixel) in master.enumerate_pixels_mut() {
                    let bg = pixel.0;
                    let fg = layer_rgba.get_pixel(x, y).0;
                    
                    // Optimized: If FG alpha is 0, skip
                    if fg[3] == 0 { continue; }

                    let out = LyxalImage::blend_pixel(bg, fg, mode, opacity);
                    *pixel = image::Rgba(out);
                }
            }
        }
        
        // Update final image
        img = LyxalImage::from_rgba(master);
    }

    img.to_bytes(img.format)
}