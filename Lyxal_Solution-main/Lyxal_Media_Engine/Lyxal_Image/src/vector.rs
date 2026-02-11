use crate::core::LyxalImage;
use crate::error::{LyxalError, LyxalResult};
use tiny_skia::{Pixmap, Transform};
use usvg::{Options, Tree, TreeParsing}; 

impl LyxalImage {
    pub fn overlay_svg(&mut self, svg_data: &str, x: i32, y: i32, scale: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
            let rgba_img = img.to_rgba8();
            let width = rgba_img.width();
            let height = rgba_img.height();

            let mut pixmap = Pixmap::new(width, height)
                .ok_or(LyxalError::VectorError("Pixmap alloc failed".into()))?;
            
            pixmap.data_mut().copy_from_slice(&rgba_img);

            let mut opt = Options::default();
            opt.resources_dir = None; // SANDBOX: Interdit chargement fichiers externes
            
            // 1. Parse USVG Tree (DOM)
            let usvg_tree = Tree::from_str(svg_data, &opt)
                .map_err(|e| LyxalError::VectorError(format!("SVG Parse Error: {}", e)))?;

            // 2. Convert to RESVG Tree (Render Tree)
            let rtree = resvg::Tree::from_usvg(&usvg_tree);

            let transform = Transform::from_translate(x as f32, y as f32)
                .post_scale(scale, scale);

            // 3. Render
            rtree.render(transform, &mut pixmap.as_mut());
             
            *img = image::DynamicImage::ImageRgba8(
                image::RgbaImage::from_raw(width, height, pixmap.take())
                    .ok_or(LyxalError::InternalError("Failed to reconstruct image from vector buffer".into()))?
            );
            Ok(())
        })
    }
}