use crate::core::LyxalImage;
use crate::error::{LyxalError, LyxalResult};
use tiny_skia::{Pixmap, Transform};
use usvg::{Options, Tree, FitTo};

impl LyxalImage {
    pub fn overlay_svg(&mut self, svg_data: &str, x: i32, y: i32, scale: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
            let rgba_img = img.to_rgba8();
            let width = rgba_img.width();
            let height = rgba_img.height();

            let mut pixmap = Pixmap::new(width, height)
                .ok_or(LyxalError::VectorError("Pixmap alloc failed".into()))?;
            
            pixmap.data_mut().copy_from_slice(&rgba_img);

            let opt = Options::default();
            // Parsing safe
            let tree = Tree::from_str(svg_data, &opt)
                .map_err(|e| LyxalError::VectorError(e.to_string()))?;

            let transform = Transform::from_translate(x as f32, y as f32)
                .post_scale(scale, scale);

            resvg::render(&tree, FitTo::Original, transform, pixmap.as_mut())
                .ok_or(LyxalError::VectorError("Render failed".into()))?;

            *img = image::DynamicImage::ImageRgba8(
                image::RgbaImage::from_raw(width, height, pixmap.take()).unwrap()
            );
            Ok(())
        })
    }
}