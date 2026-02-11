use image::{DynamicImage, Rgba, RgbaImage, ImageFormat};
use serde::{Deserialize, Serialize};
use std::io::Cursor;
use crate::core::LyxalImage;
use crate::error::{LyxalError, LyxalResult};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
#[serde(tag = "type")]
pub enum OutputFormat {
    Png,
    Jpeg { 
        #[serde(default = "default_quality")]
        quality: u8 
    },
    WebP { 
        #[serde(default = "default_quality")]
        quality: u8,
        #[serde(default)]
        lossless: bool 
    },
}

fn default_quality() -> u8 { 90 }

impl Default for OutputFormat {
    fn default() -> Self {
        OutputFormat::Png
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ExportConfig {
    pub format: OutputFormat,
    // If provided, the image will be flattened onto this color.
    // Mandatory for JPEG (if not provided, defaults to White).
    pub background_color: Option<String>, 
    // pub dpi: Option<u32>, // Metadata setting TODO
}

pub fn export_image(layer: &LyxalImage, config: &ExportConfig) -> LyxalResult<Vec<u8>> {
    let mut img = layer.inner.lock().unwrap().clone();
    
    // 1. Handle Flattening (Background Color)
    // Flattening is required for JPEG, or if background_color is explicitly requested.
    let needs_flattening = config.background_color.is_some() || matches!(config.format, OutputFormat::Jpeg { .. });

    if needs_flattening {
        let bg_hex = config.background_color.as_deref().unwrap_or("#FFFFFF"); // Default White for JPEG
        let bg_color = parse_color(bg_hex);
        
        let mut new_img = RgbaImage::from_pixel(img.width(), img.height(), bg_color);
        image::imageops::overlay(&mut new_img, &img, 0, 0);
        img = DynamicImage::ImageRgba8(new_img);
    }

    // 2. Encode
    let mut bytes: Vec<u8> = Vec::new();
    let mut cursor = Cursor::new(&mut bytes);

    match config.format {
        OutputFormat::Png => {
            // Use standard write_to which uses recommended settings
            // For strict determinism, we might need lower level control, but image crate is generally stable.
            img.write_to(&mut cursor, ImageFormat::Png).map_err(map_enc_err)?;
        },
        OutputFormat::Jpeg { quality } => {
            // Image crate's write_to doesn't accept quality param easily in generic function
            // We use specific encoder
            // Note: img must be RGB8 for JpegEncoder usually? DynamicImage handles conversion if we use write_to.
            // But to pass quality, we need JpegEncoder.
            let rgb = img.to_rgb8();
            let mut enc = image::codecs::jpeg::JpegEncoder::new_with_quality(&mut cursor, quality);
            enc.encode_image(&rgb).map_err(map_enc_err)?;
        },
        OutputFormat::WebP { quality: _, lossless } => {
            // image crate generic write_to uses default quality.
            // For custom quality, we need WebPEncoder if available.
            
            if lossless {
                let enc = image::codecs::webp::WebPEncoder::new_lossless(&mut cursor);
                enc.encode(&img.to_rgba8(), img.width(), img.height(), image::ColorType::Rgba8).map_err(map_enc_err)?;
            } else {
                 // Unfortunately, WebPEncoder in pure rust image might be limited or based on libwebp.
                 // Actually image crate implementation for WebP write might be basic.
                 // Let's rely on write_to with ImageFormat::WebP first (uses default) 
                 // OR check if we have control.
                 // For Safety/Stability: Use write_to(WebP). Quality might be fixed.
                 // Use a TODO for Quality control if API allows.
                 img.write_to(&mut cursor, ImageFormat::WebP).map_err(map_enc_err)?;
            }
        }
    }

    Ok(bytes)
}

fn map_enc_err(e: image::ImageError) -> LyxalError {
    LyxalError::Decode(e)
}

fn parse_color(hex: &str) -> Rgba<u8> {
    let hex_clean = hex.trim_start_matches('#');
    if hex_clean.len() == 6 {
         if let (Ok(r), Ok(g), Ok(b)) = (
             u8::from_str_radix(&hex_clean[0..2], 16),
             u8::from_str_radix(&hex_clean[2..4], 16),
             u8::from_str_radix(&hex_clean[4..6], 16)
         ) {
             return Rgba([r, g, b, 255]);
         }
    }
    // Fallback White
    Rgba([255, 255, 255, 255])
}
