use image::{DynamicImage, RgbaImage, GenericImage, GenericImageView, Rgba, Pixel};
use crate::error::LyxalResult;
use crate::pipeline::Effect;
use crate::core::LyxalImage;
use tiny_skia; // Needed for Color return type match

pub fn apply_effects(layer: &mut LyxalImage, effects: &[Effect]) -> LyxalResult<()> {
    for effect in effects {
        match effect {
            Effect::DropShadow { offset_x, offset_y, blur, color, opacity } => {
                apply_drop_shadow(layer, *offset_x, *offset_y, *blur, color, *opacity)?;
            },
            Effect::InnerShadow { offset_x, offset_y, blur, color, opacity } => {
                apply_inner_shadow(layer, *offset_x, *offset_y, *blur, color, *opacity)?;
            },
            Effect::Glow { blur, color, opacity, inner } => {
                 apply_glow(layer, *blur, color, *opacity, inner.unwrap_or(false))?;
            },
            Effect::Outline { width, color, position } => {
                 apply_outline(layer, *width, color, position.as_deref())?;
            }
        }
    }
    Ok(())
}

fn parse_color_rgba(hex: &str, opacity: f32) -> Rgba<u8> {
    let c = LyxalImage::parse_color(hex).unwrap_or(tiny_skia::Color::BLACK);
    let r = (c.red() * 255.0) as u8;
    let g = (c.green() * 255.0) as u8;
    let b = (c.blue() * 255.0) as u8;
    let a = (opacity.clamp(0.0, 1.0) * 255.0) as u8;
    Rgba([r, g, b, a])
}

fn apply_drop_shadow(layer: &mut LyxalImage, ox: f32, oy: f32, blur: f32, color: &str, opacity: f32) -> LyxalResult<()> {
    if opacity <= 0.0 { return Ok(()); }
    
    let w = layer.width();
    let h = layer.height();
    let original = layer.to_rgba8(); // Clone
    
    // 1. Extract Alpha & Colorize base
    let shadow_color = parse_color_rgba(color, opacity);
    let mut shadow_map = RgbaImage::new(w, h);
    
    for y in 0..h {
        for x in 0..w {
            let p = original.get_pixel(x, y);
            let alpha = p[3];
            if alpha > 0 {
                // Shadow map: solid color with source alpha
                let final_a = ((alpha as f32 / 255.0) * (shadow_color[3] as f32)).min(255.0) as u8;
                shadow_map.put_pixel(x, y, Rgba([shadow_color[0], shadow_color[1], shadow_color[2], final_a]));
            }
        }
    }
    
    // 2. Blur
    let blurred_shadow = if blur > 0.0 {
        image::imageops::blur(&shadow_map, blur)
    } else {
        shadow_map
    };
    
    // 3. Composite
    let mut final_img = RgbaImage::new(w, h);
    
    // Draw Shadow with Offset
    let offset_x = ox.round() as i32;
    let offset_y = oy.round() as i32;
    
    image::imageops::overlay(&mut final_img, &blurred_shadow, offset_x as i64, offset_y as i64); 
    // Wait, overlay takes i64 coeffs
    
    // Draw Original on top
    image::imageops::overlay(&mut final_img, &original, 0, 0);
    
    layer.replace_buffer(DynamicImage::ImageRgba8(final_img));
    
    Ok(())
}

fn apply_inner_shadow(layer: &mut LyxalImage, ox: f32, oy: f32, blur: f32, color: &str, opacity: f32) -> LyxalResult<()> {
    if opacity <= 0.0 { return Ok(()); }
    
    // Inner Shadow Logic:
    // 1. Create Inverted Alpha Map (Outside = Opaque, Inside = Transparent)
    // 2. Blur it.
    // 3. Offset it.
    // 4. Clip it to Original Alpha.
    // 5. Composite ON TOP.
    
    let w = layer.width();
    let h = layer.height();
    let original = layer.to_rgba8();
    
    let shadow_color = parse_color_rgba(color, opacity);
    
    // 1. Inverted Mask
    let mut inverted_map = RgbaImage::new(w, h);
    for y in 0..h {
        for x in 0..w {
            let p = original.get_pixel(x, y);
             // Invert alpha: 255 - alpha
             // We want "Outside" to cast shadow "Inside".
             // Outside pixels (A=0) -> become Mask A=255.
             // Inside pixels (A=255) -> become Mask A=0.
             let inv_a = 255u8.saturating_sub(p[3]);
             // We only care about Alpha for the blur source. 
             // Color doesn't matter yet, but usually we blur the Shadow Color.
             // So: Pixel = ShadowColor, Alpha = inv_a.
             inverted_map.put_pixel(x, y, Rgba([shadow_color[0], shadow_color[1], shadow_color[2], inv_a]));
        }
    }
    
    // 2. Blur
    let blurred_inv = if blur > 0.0 {
        image::imageops::blur(&inverted_map, blur)
    } else {
        inverted_map
    };
    
    // 3. Composite (Offset & Clip)
    let mut final_img = original.clone();
    let offset_x = ox.round() as i32;
    let offset_y = oy.round() as i32;
    
    for y in 0..h {
        for x in 0..w {
            // Original pixel
            let p_orig = original.get_pixel(x, y);
            if p_orig[3] == 0 { continue; } // Optimization: if original is transparent, no inner shadow visible (clipped)
            
            // Sample Blurred Inverted Map at relative offset
            // We want shadow from *offset* position.
            // Actually, standard Inner Shadow: Light comes from Top Left -> Shadow is at Top Left INSIDE?
            // If OX=5, OY=5.
            // Usually implemented as: Mask * Shifted(Blurred(Inverted)).
            let sx = x as i32 - offset_x;
            let sy = y as i32 - offset_y;
            

            
            // Sample Blurred Inverted Map at relative offset
            let shadow_alpha = if sx >= 0 && sx < w as i32 && sy >= 0 && sy < h as i32 {
                blurred_inv.get_pixel(sx as u32, sy as u32)[3]
            } else {
                 // Off-screen read for Inverted Map implies "Outside" => Opaque
                 255
            };
            
            if shadow_alpha > 0 {
                // Composite Shadow over Original
                let p_orig = original.get_pixel(x, y); // We know x,y inside bounds
                
                // Mask by Original Alpha to keep shadow inside
                let mask_factor = p_orig[3] as f32 / 255.0;
                let eff_alpha_f = shadow_alpha as f32 * mask_factor;
                let eff_alpha = eff_alpha_f as u8;
                
                if eff_alpha > 0 {
                    // Standard Over blend
                    let sa = eff_alpha as f32 / 255.0;
                    let da = p_orig[3] as f32 / 255.0;
                    
                    let out_a = sa + da * (1.0 - sa);
                    
                    // Shadow Color is used for RGB source
                    // Note: shadow_color is global from outer scope
                    let sr = shadow_color[0] as f32;
                    let sg = shadow_color[1] as f32;
                    let sb = shadow_color[2] as f32;
                    
                    let dr = p_orig[0] as f32;
                    let dg = p_orig[1] as f32;
                    let db = p_orig[2] as f32;
                    
                    let r = (sr * sa + dr * da * (1.0 - sa)) / out_a;
                    let g = (sg * sa + dg * da * (1.0 - sa)) / out_a;
                    let b = (sb * sa + db * da * (1.0 - sa)) / out_a;
                    
                    final_img.put_pixel(x, y, Rgba([r as u8, g as u8, b as u8, (out_a * 255.0) as u8]));
                }
            }
        }
    }
    
    layer.replace_buffer(DynamicImage::ImageRgba8(final_img));
    Ok(())
}

fn apply_glow(layer: &mut LyxalImage, blur: f32, color: &str, opacity: f32, inner: bool) -> LyxalResult<()> {
    // Outer Glow is basically a centered Drop Shadow with a specific color.
    if !inner {
        apply_drop_shadow(layer, 0.0, 0.0, blur, color, opacity)
    } else {
        // Inner Glow = Centered Inner Shadow
        apply_inner_shadow(layer, 0.0, 0.0, blur, color, opacity)
    }
}

fn apply_outline(layer: &mut LyxalImage, width: f32, color: &str, position: Option<&str>) -> LyxalResult<()> {
    if width <= 0.0 { return Ok(()); }
    
    // Safety cap to prevent DoS with huge outline radius
    let width = width.min(50.0);
    
    let pos = position.unwrap_or("outside");
    
    let w = layer.width();
    let h = layer.height();
    let original = layer.to_rgba8();
    let outline_color = parse_color_rgba(color, 1.0); // Full opacity for outline stroke itself
    
    let width_u = width.ceil() as i32;
    let width_sq = width * width;
    
    let mut final_img = original.clone();
    
    if pos == "outside" {
        // Only checking transparent pixels
        // Parallelization would be great here... but kept simple.
        for y in 0..h {
            for x in 0..w {
                let p = original.get_pixel(x, y);
                // Optimization: if pixel is fully opaque, it's not part of outside outline (unless center/inside?)
                // Spec says "outside" priority.
                if p[3] < 255 { 
                     // It is transparent or semi. If fully transparent, we search neighbors.
                     // If semi-transparent, outline is usually BEHIND or blended?
                     // Standard "Stroke" usually adds solid pixels.
                     
                     if p[3] == 0 {
                         let mut found = false;
                         'search: for dy in -width_u..=width_u {
                             for dx in -width_u..=width_u {
                                 if dx*dx + dy*dy > width_sq as i32 { continue; } 
                                 let nx = x as i32 + dx;
                                 let ny = y as i32 + dy;
                                 if nx >= 0 && nx < w as i32 && ny >= 0 && ny < h as i32 {
                                     if original.get_pixel(nx as u32, ny as u32)[3] > 0 {
                                         found = true;
                                         break 'search;
                                     }
                                 }
                             }
                         }
                         if found {
                             final_img.put_pixel(x, y, outline_color);
                         }
                     }
                }
            }
        }
    } else {
        // TODO: Inside/Center logic if requested later.
        // For now, only Outside is fully implemented.
    }
    
    layer.replace_buffer(DynamicImage::ImageRgba8(final_img));
    Ok(())
}
