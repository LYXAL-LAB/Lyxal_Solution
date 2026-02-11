use crate::core::LyxalImage;
use crate::error::{LyxalResult, LyxalError};

impl LyxalImage {
    pub fn blur(&mut self, sigma: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
            *img = img.blur(sigma);
            Ok(())
        })
    }

    pub fn grayscale(&mut self) -> LyxalResult<()> {
        self.with_inner(|img| {
            *img = img.grayscale();
            Ok(())
        })
    }
    
    // --- Bloc 1: Ajustements Photo ---
    
    pub fn brightness(&mut self, value: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
            let offset = (value * 255.0) as i32;
            image::imageops::brighten(img, offset);
            Ok(())
        })
    }

    pub fn contrast(&mut self, value: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
            image::imageops::contrast(img, value);
            Ok(())
        })
    }

    pub fn saturation(&mut self, value: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
            let factor = 1.0 + value;
            let rgba = img.to_rgba8();
            let mut new_rgba = image::ImageBuffer::new(rgba.width(), rgba.height());
            
            for (x, y, pixel) in rgba.enumerate_pixels() {
                let r = pixel[0] as f32;
                let g = pixel[1] as f32;
                let b = pixel[2] as f32;
                let a = pixel[3];
                
                // Rec 601 Luma
                let luma = 0.299 * r + 0.587 * g + 0.114 * b;
                
                let new_r = (luma + (r - luma) * factor).clamp(0.0, 255.0) as u8;
                let new_g = (luma + (g - luma) * factor).clamp(0.0, 255.0) as u8;
                let new_b = (luma + (b - luma) * factor).clamp(0.0, 255.0) as u8;
                
                new_rgba.put_pixel(x, y, image::Rgba([new_r, new_g, new_b, a]));
            }
            *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }

    pub fn temperature(&mut self, value: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
            let rgba = img.to_rgba8();
            let mut new_rgba = image::ImageBuffer::new(rgba.width(), rgba.height());
            
            let r_scale = if value > 0.0 { 1.0 + value * 0.4 } else { 1.0 };
            let b_scale = if value < 0.0 { 1.0 + value.abs() * 0.4 } else { 1.0 };
             
            for (x, y, pixel) in rgba.enumerate_pixels() {
                let r = (pixel[0] as f32 * r_scale).clamp(0.0, 255.0) as u8;
                let g = pixel[1];
                let b = (pixel[2] as f32 * b_scale).clamp(0.0, 255.0) as u8;
                new_rgba.put_pixel(x, y, image::Rgba([r, g, b, pixel[3]]));
            }
            *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }

    pub fn tint(&mut self, value: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
            let rgba = img.to_rgba8();
            let mut new_rgba = image::ImageBuffer::new(rgba.width(), rgba.height());
            
            let g_scale = if value < 0.0 { 1.0 + value.abs() * 0.4 } else { 1.0 };
            let rb_scale = if value > 0.0 { 1.0 + value * 0.4 } else { 1.0 };

            for (x, y, pixel) in rgba.enumerate_pixels() {
                let r = (pixel[0] as f32 * rb_scale).clamp(0.0, 255.0) as u8;
                let g = (pixel[1] as f32 * g_scale).clamp(0.0, 255.0) as u8;
                let b = (pixel[2] as f32 * rb_scale).clamp(0.0, 255.0) as u8;
                new_rgba.put_pixel(x, y, image::Rgba([r, g, b, pixel[3]]));
            }
            *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }
    
    pub fn shadows(&mut self, value: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
            let rgba = img.to_rgba8();
            let mut new_rgba = image::ImageBuffer::new(rgba.width(), rgba.height());
            
            for (x, y, pixel) in rgba.enumerate_pixels() {
                let mut data = [pixel[0], pixel[1], pixel[2]];
                let max_c = std::cmp::max(data[0], std::cmp::max(data[1], data[2]));
                if max_c < 128 {
                    let t = (128 - max_c) as f32 / 128.0;
                    let boost = t * value * 50.0; 
                    data[0] = (data[0] as f32 + boost).clamp(0.0, 255.0) as u8;
                    data[1] = (data[1] as f32 + boost).clamp(0.0, 255.0) as u8;
                    data[2] = (data[2] as f32 + boost).clamp(0.0, 255.0) as u8;
                }
                new_rgba.put_pixel(x, y, image::Rgba([data[0], data[1], data[2], pixel[3]]));
            }
             *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }

    pub fn highlights(&mut self, value: f32) -> LyxalResult<()> {
         self.with_inner(|img| {
            let rgba = img.to_rgba8();
            let mut new_rgba = image::ImageBuffer::new(rgba.width(), rgba.height());
            
            for (x, y, pixel) in rgba.enumerate_pixels() {
                let mut data = [pixel[0], pixel[1], pixel[2]];
                let min_c = std::cmp::min(data[0], std::cmp::min(data[1], data[2]));
                 if min_c > 128 {
                    let t = (min_c - 128) as f32 / 128.0;
                    let darken = t * value * 50.0;
                    data[0] = (data[0] as f32 - darken).clamp(0.0, 255.0) as u8;
                    data[1] = (data[1] as f32 - darken).clamp(0.0, 255.0) as u8;
                    data[2] = (data[2] as f32 - darken).clamp(0.0, 255.0) as u8;
                 }
                new_rgba.put_pixel(x, y, image::Rgba([data[0], data[1], data[2], pixel[3]]));
            }
             *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }

    pub fn sharpness(&mut self, value: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
             let sigma = 1.0;
             let blurred = img.blur(sigma);
             
             let rgba = img.to_rgba8();
             let blur_rgba = blurred.to_rgba8();
             let mut new_rgba = image::ImageBuffer::new(rgba.width(), rgba.height());

             for (x, y, pixel) in rgba.enumerate_pixels() {
                 let b_pixel = blur_rgba.get_pixel(x, y);
                 let r = pixel[0] as f32;
                 let g = pixel[1] as f32;
                 let b = pixel[2] as f32;
                 
                 let br = b_pixel[0] as f32;
                 let bg = b_pixel[1] as f32;
                 let bb = b_pixel[2] as f32;
                 
                 let nr = (r + (r - br) * value).clamp(0.0, 255.0) as u8;
                 let ng = (g + (g - bg) * value).clamp(0.0, 255.0) as u8;
                 let nb = (b + (b - bb) * value).clamp(0.0, 255.0) as u8;
                 
                 new_rgba.put_pixel(x, y, image::Rgba([nr, ng, nb, pixel[3]]));
             }

             *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }
    
    pub fn vignette(&mut self, value: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
             let rgba = img.to_rgba8();
             let width = rgba.width() as f32;
             let height = rgba.height() as f32;
             let cx = width / 2.0;
             let cy = height / 2.0;
             let max_dist = (cx*cx + cy*cy).sqrt();
             
             let mut new_rgba = image::ImageBuffer::new(rgba.width(), rgba.height());
             
             for (x, y, pixel) in rgba.enumerate_pixels() {
                 let dx = x as f32 - cx;
                 let dy = y as f32 - cy;
                 let dist = (dx*dx + dy*dy).sqrt();
                 
                 let d = dist / max_dist;
                 
                 let darkening = d * value;
                 let factor = (1.0 - darkening).clamp(0.0, 1.0);
                 
                 let r = (pixel[0] as f32 * factor) as u8;
                 let g = (pixel[1] as f32 * factor) as u8;
                 let b = (pixel[2] as f32 * factor) as u8;
                 
                 new_rgba.put_pixel(x, y, image::Rgba([r, g, b, pixel[3]]));
             }
             *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }

     pub fn sepia(&mut self, value: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
             let rgba = img.to_rgba8();
             let mut new_rgba = image::ImageBuffer::new(rgba.width(), rgba.height());
             
             for (x, y, pixel) in rgba.enumerate_pixels() {
                 let r = pixel[0] as f32;
                 let g = pixel[1] as f32;
                 let b = pixel[2] as f32;
                 
                 let tr = 0.393*r + 0.769*g + 0.189*b;
                 let tg = 0.349*r + 0.686*g + 0.168*b;
                 let tb = 0.272*r + 0.534*g + 0.131*b;
                 
                 let nr = r * (1.0 - value) + tr * value;
                 let ng = g * (1.0 - value) + tg * value;
                 let nb = b * (1.0 - value) + tb * value;
                 
                 new_rgba.put_pixel(x, y, image::Rgba([
                     nr.clamp(0.0, 255.0) as u8,
                     ng.clamp(0.0, 255.0) as u8,
                     nb.clamp(0.0, 255.0) as u8,
                     pixel[3]
                 ]));
             }
             *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }
    // --- Bloc 3: Effets Artistiques ---
    
    pub fn pixelate(&mut self, size: u32) -> LyxalResult<()> {
        self.with_inner(|img| {
             let rgba = img.to_rgba8();
             let width = rgba.width();
             let height = rgba.height();
             let mut new_rgba = image::ImageBuffer::new(width, height);
             
             // Iterate blocks
             for y in (0..height).step_by(size as usize) {
                 for x in (0..width).step_by(size as usize) {
                     // Get color of top-left pixel (Simple approach for aesthetics)
                     // or Average? Top-left is standard retro style.
                     let pixel = rgba.get_pixel(x, y);
                     
                     // Fill block
                     for by in 0..size {
                         for bx in 0..size {
                             let nx = x + bx;
                             let ny = y + by;
                             if nx < width && ny < height {
                                 new_rgba.put_pixel(nx, ny, *pixel);
                             }
                         }
                     }
                 }
             }
             *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }

    pub fn posterize(&mut self, levels: u8) -> LyxalResult<()> {
        self.with_inner(|img| {
            let rgba = img.to_rgba8();
            let mut new_rgba = image::ImageBuffer::new(rgba.width(), rgba.height());
            
            // Step size = 255 / (levels - 1)
            let step = 255.0 / (levels as f32 - 1.0);
            
            for (x, y, pixel) in rgba.enumerate_pixels() {
                let r = (pixel[0] as f32 / step).round() * step;
                let g = (pixel[1] as f32 / step).round() * step;
                let b = (pixel[2] as f32 / step).round() * step;
                
                new_rgba.put_pixel(x, y, image::Rgba([
                    r.clamp(0.0, 255.0) as u8,
                    g.clamp(0.0, 255.0) as u8,
                    b.clamp(0.0, 255.0) as u8,
                    pixel[3]
                ]));
            }
             *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }

    pub fn noise(&mut self, intensity: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
            let rgba = img.to_rgba8();
            let mut new_rgba = image::ImageBuffer::new(rgba.width(), rgba.height());
            
            // Simple LCG PRNG for determinism
            let mut seed: u32 = 12345;
            let mut lcg = || {
                seed = seed.wrapping_mul(1664525).wrapping_add(1013904223);
                (seed >> 8) as i32 // some 'random' byte equivalent
            };
            
            let noise_range = (intensity * 255.0) as i32;
            let half_range = noise_range / 2;

            for (x, y, pixel) in rgba.enumerate_pixels() {
                // Add RGB Noise
                let nr = (lcg() % noise_range) - half_range;
                let ng = (lcg() % noise_range) - half_range;
                let nb = (lcg() % noise_range) - half_range;
                
                let r = (pixel[0] as i32 + nr).clamp(0, 255) as u8;
                let g = (pixel[1] as i32 + ng).clamp(0, 255) as u8;
                let b = (pixel[2] as i32 + nb).clamp(0, 255) as u8;
                
                new_rgba.put_pixel(x, y, image::Rgba([r, g, b, pixel[3]]));
            }
             *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }
    
    pub fn duotone(&mut self, c1_hex: &str, c2_hex: &str) -> LyxalResult<()> {
         self.with_inner(|img| {
            // Parse Colors
            fn parse_hex(h: &str) -> Result<[u8; 3], String> {
                let r = u8::from_str_radix(&h[1..3], 16).map_err(|_| "Invalid Hex R")?;
                let g = u8::from_str_radix(&h[3..5], 16).map_err(|_| "Invalid Hex G")?;
                let b = u8::from_str_radix(&h[5..7], 16).map_err(|_| "Invalid Hex B")?;
                Ok([r, g, b])
            }
            
            let c1 = parse_hex(c1_hex).map_err(|msg| LyxalError::InvalidParam(msg.to_string()))?;
            let c2 = parse_hex(c2_hex).map_err(|msg| LyxalError::InvalidParam(msg.to_string()))?;
            
            let rgba = img.to_rgba8();
             let mut new_rgba = image::ImageBuffer::new(rgba.width(), rgba.height());

             for (x, y, pixel) in rgba.enumerate_pixels() {
                 // Convert to Luma (0..1)
                 let r = pixel[0] as f32;
                 let g = pixel[1] as f32;
                 let b = pixel[2] as f32;
                 let luma = (0.299*r + 0.587*g + 0.114*b) / 255.0; // 0.0 to 1.0
                 
                 // Interpolate between c1 and c2
                 let nr = (c1[0] as f32 * (1.0 - luma) + c2[0] as f32 * luma) as u8;
                 let ng = (c1[1] as f32 * (1.0 - luma) + c2[1] as f32 * luma) as u8;
                 let nb = (c1[2] as f32 * (1.0 - luma) + c2[2] as f32 * luma) as u8;
                 
                 new_rgba.put_pixel(x, y, image::Rgba([nr, ng, nb, pixel[3]]));
             }
             
             *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }

    pub fn glitch_horizontal(&mut self) -> LyxalResult<()> {
        self.with_inner(|img| {
             let rgba = img.to_rgba8();
             let width = rgba.width();
             let height = rgba.height();
             let mut new_rgba = image::ImageBuffer::new(width, height);
             
             // Simple deterministic glitch: Shift Red Channel Left 5px, Blue Right 5px
             // For each row, maybe change shift slightly? No, keep it simple/fast.
             
             for y in 0..height {
                 for x in 0..width {
                     let (_, _, _, a) = rgba.get_pixel(x, y).0.into(); // A from original pos
                     
                     // Red shift left
                     let rx = (x as i32 - 10).clamp(0, width as i32 - 1) as u32;
                     let r = rgba.get_pixel(rx, y)[0];
                     
                     // Green original
                     let g = rgba.get_pixel(x, y)[1];
                     
                     // Blue shift right
                     let bx = (x as i32 + 10).clamp(0, width as i32 - 1) as u32;
                     let b = rgba.get_pixel(bx, y)[2];
                     
                     new_rgba.put_pixel(x, y, image::Rgba([r, g, b, a]));
                 }
             }
             *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }

    pub fn glitch_vertical(&mut self) -> LyxalResult<()> {
         self.with_inner(|img| {
             let rgba = img.to_rgba8();
             let width = rgba.width();
             let height = rgba.height();
             let mut new_rgba = image::ImageBuffer::new(width, height);
             
             // Shift Green Up 10, Red Down 10
             for y in 0..height {
                 for x in 0..width {
                     let (_, _, _, a) = rgba.get_pixel(x, y).0.into();
                     
                     // Red down
                     let ry = (y as i32 + 10).clamp(0, height as i32 - 1) as u32;
                     let r = rgba.get_pixel(x, ry)[0];
                     
                     // Green up
                     let gy = (y as i32 - 10).clamp(0, height as i32 - 1) as u32;
                     let g = rgba.get_pixel(x, gy)[1];
                     
                     // Blue original
                     let b = rgba.get_pixel(x, y)[2];
                     
                     new_rgba.put_pixel(x, y, image::Rgba([r, g, b, a]));
                 }
             }
             *img = image::DynamicImage::ImageRgba8(new_rgba);
            Ok(())
        })
    }

    // --- Bloc 2: Blend Modes ---
    
    // --- Bloc 2: Blend Modes ---
    
    // Helper pure function for blending two pixels
    fn blend_channel(bg: f32, fg: f32, mode: &str) -> f32 {
         match mode {
             "multiply" => bg * fg,
             "screen" => 1.0 - (1.0 - bg) * (1.0 - fg),
             "overlay" => {
                 if bg < 0.5 { 2.0 * bg * fg } else { 1.0 - 2.0 * (1.0 - bg) * (1.0 - fg) }
             },
             "darken" => bg.min(fg),
             "lighten" => bg.max(fg),
             "difference" => (bg - fg).abs(),
             "color_burn" => {
                 if fg == 0.0 { 0.0 } else { 1.0 - ((1.0 - bg) / fg).min(1.0) }
             },
             "color_dodge" => {
                 if fg == 1.0 { 1.0 } else { (bg / (1.0 - fg)).min(1.0) }
             },
             "soft_light" => {
                 (1.0 - 2.0 * fg) * bg * bg + 2.0 * fg * bg
             },
             _ => fg // Normal replace or fallback
         }
    }

    pub fn blend_pixel(bg: [u8; 4], fg: [u8; 4], mode: &str, opacity: f32) -> [u8; 4] {
        let alpha_fg = (fg[3] as f32 / 255.0) * opacity;
        let alpha_bg = bg[3] as f32 / 255.0;
        
        // Simple alpha compositing:
        // Result = (Src * Alpha + Dst * (1 - Alpha))
        // Here Src is the Blended RGB.
        
        let r_bg = bg[0] as f32 / 255.0;
        let g_bg = bg[1] as f32 / 255.0;
        let b_bg = bg[2] as f32 / 255.0;
        
        let r_fg = fg[0] as f32 / 255.0;
        let g_fg = fg[1] as f32 / 255.0;
        let b_fg = fg[2] as f32 / 255.0;
        
        let r_blend = Self::blend_channel(r_bg, r_fg, mode);
        let g_blend = Self::blend_channel(g_bg, g_fg, mode);
        let b_blend = Self::blend_channel(b_bg, b_fg, mode);
        
        // Final Composite:
        // Out = Blend * AlphaFg + Bg * (1 - AlphaFg)
        // This assumes Normal alpha blending of the "Blended Color" onto Background.
        
        let r_out = r_blend * alpha_fg + r_bg * (1.0 - alpha_fg);
        let g_out = g_blend * alpha_fg + g_bg * (1.0 - alpha_fg);
        let b_out = b_blend * alpha_fg + b_bg * (1.0 - alpha_fg);
        
        // Output Alpha? 
        // Typically: OutAlpha = AlphaFg + AlphaBg * (1 - AlphaFg)
        let a_out = alpha_fg + alpha_bg * (1.0 - alpha_fg);
        
        [
            (r_out.clamp(0.0, 1.0) * 255.0) as u8,
            (g_out.clamp(0.0, 1.0) * 255.0) as u8,
            (b_out.clamp(0.0, 1.0) * 255.0) as u8,
            (a_out.clamp(0.0, 1.0) * 255.0) as u8
        ]
    }

    pub fn data_blend(&mut self, mode: &str, color_hex: &str) -> LyxalResult<()> {
        self.with_inner(|img| {
             let r_c = u8::from_str_radix(&color_hex[1..3], 16).map_err(|_| LyxalError::InvalidParam("Invalid Hex R".into()))?;
             let g_c = u8::from_str_radix(&color_hex[3..5], 16).map_err(|_| LyxalError::InvalidParam("Invalid Hex G".into()))?;
             let b_c = u8::from_str_radix(&color_hex[5..7], 16).map_err(|_| LyxalError::InvalidParam("Invalid Hex B".into()))?;
             
             let rgba = img.to_rgba8();
             let mut new_rgba = image::ImageBuffer::new(rgba.width(), rgba.height());
             
             let fg = [r_c, g_c, b_c, 255];
             
             for (x, y, pixel) in rgba.enumerate_pixels() {
                 let bg = pixel.0;
                 let out = Self::blend_pixel(bg, fg, mode, 1.0); // Opacity 1.0 for legacy call
                 new_rgba.put_pixel(x, y, image::Rgba(out));
             }
             *img = image::DynamicImage::ImageRgba8(new_rgba);
             Ok(())
        })
    }
}