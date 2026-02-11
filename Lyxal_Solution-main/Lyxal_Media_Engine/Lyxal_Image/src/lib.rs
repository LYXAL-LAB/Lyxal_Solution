pub mod core;
pub mod error;
pub mod context;
pub mod ops;
pub mod filters;
pub mod vector;
pub mod shapes;
pub mod text;
pub mod ml;
pub mod effects;
pub mod templates; // NEW
pub mod export;
pub mod secure;
pub mod pipeline;

// Exports publics pour faciliter l'utilisation externe
pub use core::LyxalImage;
pub use error::{LyxalError, LyxalResult};
pub use context::ImageContext;
pub use pipeline::process;
pub use ml::FaceDetector;

// Public High-Level API
pub fn render_final(
    template: &templates::Template, 
    preset: Option<&templates::Preset>, 
    export_cfg: &export::ExportConfig,
    env: Option<&lyxal_text::env::TextEnvironment>
) -> error::LyxalResult<Vec<u8>> {
    // 1. Resolve Template + Preset -> LayerConfigs
    let layers = templates::resolve(template, preset)?;
    
    // 2. Determine Canvas Size
    // For now, assume 800x800 default. real world would read from template metadata.
    let width = 800; 
    let height = 800; 
    
    // Create Blank Context
    let ctx = context::ImageContext::default();
    let img = core::LyxalImage::new_empty(width, height);
    
    // 3. Run Pipeline (Layers only)
    // Serialize layers back to JSON to feed `pipeline::process`.
    let layers_json = serde_json::to_string(&serde_json::json!({ "layers": layers })).unwrap();
    
    // Image bytes? We pass an empty PNG representing the canvas.
    let empty_png = img.to_bytes(image::ImageFormat::Png)?;
    
    let result_bytes = pipeline::process(&empty_png, &layers_json, ctx, env)?;
    
    // 4. Export
    // valid LyxalImage from result_bytes
    let final_img = core::LyxalImage::from_bytes(&result_bytes, &context::ImageContext::default())?;
    
    export::export_image(&final_img, export_cfg)
}