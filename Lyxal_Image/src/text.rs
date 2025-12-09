use crate::core::LyxalImage;
use crate::error::{LyxalResult, LyxalError};
use cosmic_text::{Attrs, Buffer, FontSystem, Metrics, Shapable, SwashCache};
use image::{GenericImage, Rgba};
use std::sync::Mutex;

lazy_static::lazy_static! {
    static ref FONT_SYSTEM: Mutex<FontSystem> = Mutex::new(FontSystem::new());
}

impl LyxalImage {
    pub fn add_rich_text(&mut self, text: &str, x: i32, y: i32, font_size: f32, color_hex: &str) -> LyxalResult<()> {
        let mut font_system = FONT_SYSTEM.lock().map_err(|_| LyxalError::LockError)?;
        let mut swash_cache = SwashCache::new();

        let metrics = Metrics::new(font_size, font_size * 1.2); 
        let mut buffer = Buffer::new(&mut font_system, metrics);
        
        let img_width = self.with_inner(|img| Ok(img.width()))?;
        buffer.set_size(&mut font_system, (img_width as f32) - (x as f32), 2000.0);
        buffer.set_text(&mut font_system, text, Attrs::new(), cosmic_text::Shaping::Advanced);
        
        buffer.shape_until_scroll(&mut font_system);

        let c = color_hex.trim_start_matches('#');
        let r = u8::from_str_radix(&c[0..2], 16).unwrap_or(0);
        let g = u8::from_str_radix(&c[2..4], 16).unwrap_or(0);
        let b = u8::from_str_radix(&c[4..6], 16).unwrap_or(0);

        self.with_inner(|img| {
            buffer.draw(&mut font_system, &mut swash_cache, |draw_x, draw_y, _, _, color| {
                let alpha = color.a() as f32 / 255.0;
                if alpha <= 0.0 { return; }

                let px = x + draw_x;
                let py = y + draw_y;

                if px >= 0 && px < img.width() as i32 && py >= 0 && py < img.height() as i32 {
                     let existing = img.get_pixel(px as u32, py as u32);
                     let new_r = (r as f32 * alpha + (existing.0[0] as f32) * (1.0 - alpha)) as u8;
                     let new_g = (g as f32 * alpha + (existing.0[1] as f32) * (1.0 - alpha)) as u8;
                     let new_b = (b as f32 * alpha + (existing.0[2] as f32) * (1.0 - alpha)) as u8;
                     
                     img.put_pixel(px as u32, py as u32, Rgba([new_r, new_g, new_b, 255]));
                }
            });
            Ok(())
        })
    }
}