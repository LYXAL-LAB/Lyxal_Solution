use crate::core::LyxalImage;
use crate::context::ImageContext;
use crate::error::LyxalResult;
use serde::Deserialize;

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
}

#[derive(Deserialize)]
pub struct PipelineRequest {
    pub steps: Vec<PipelineStep>,
}

pub fn process(image_bytes: &[u8], request_json: &str, ctx: ImageContext) -> LyxalResult<Vec<u8>> {
    let req: PipelineRequest = serde_json::from_str(request_json)
        .map_err(|e| crate::error::LyxalError::InvalidParam(e.to_string()))?;

    if req.steps.len() > ctx.max_steps {
        return Err(crate::error::LyxalError::QuotaExceeded("Too many steps".into()));
    }

    let mut img = LyxalImage::from_bytes(image_bytes, &ctx)?;

    for step in req.steps {
        match step {
            PipelineStep::Resize { w, h } => img.resize(w, h)?,
            PipelineStep::Crop { x, y, w, h } => img.crop(x, y, w, h)?,
            PipelineStep::Blur { sigma } => img.blur(sigma)?,
            PipelineStep::Grayscale => img.grayscale()?,
            PipelineStep::Text { text, x, y, size, color } => img.add_rich_text(&text, x, y, size, &color)?,
            PipelineStep::WatermarkSvg { svg, x, y, scale } => img.overlay_svg(&svg, x, y, scale)?,
            PipelineStep::EmbedSecret { secret } => img.embed_secret(&secret)?,
        }
    }

    img.to_bytes(img.format)
}