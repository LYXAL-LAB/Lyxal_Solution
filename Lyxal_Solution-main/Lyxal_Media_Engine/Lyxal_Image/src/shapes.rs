use crate::core::LyxalImage;
use crate::error::{LyxalResult, LyxalError};
use crate::pipeline::{FillStyle, GradientStop};
use tiny_skia::{Pixmap, PathBuilder, Paint, Stroke, Transform, Color, PixmapPaint, LineCap, LineJoin, LinearGradient, RadialGradient, GradientStop as SkiaStop, Point, SpreadMode, Shader};

impl LyxalImage {

    pub fn apply_skia_draw<F>(&mut self, draw_op: F) -> LyxalResult<()>
    where
        F: FnOnce(&mut Pixmap) -> LyxalResult<()>,
    {
        self.with_inner(|img| {
             let rgba = img.to_rgba8();
             let width = rgba.width();
             let height = rgba.height();
             let data = rgba.into_raw();
             
             // Create Pixmap from buffer (copy needed because DynamicImage structure)
             // tiny-skia PixmapMut borrows, but we need to reconstruct DynamicImage after.
             // Simplest: Create Pixmap, copy data, draw, copy back.
             
             let mut pixmap = Pixmap::new(width, height).ok_or(LyxalError::InternalError("Failed to create pixmap".into()))?;
             
             // Initial content
             let src_data = pixmap.data_mut();
             if src_data.len() != data.len() {
                 return Err(LyxalError::InternalError("Buffer size mismatch".into()));
             }
             src_data.copy_from_slice(&data);
             
             // Draw
             draw_op(&mut pixmap)?;
             
             // Write back
             // We can just grab data from pixmap
             let new_data = pixmap.data().to_vec();
             let new_buf = image::RgbaImage::from_raw(width, height, new_data).ok_or(LyxalError::InternalError("Failed to reconstruct image".into()))?;
             *img = image::DynamicImage::ImageRgba8(new_buf);
             
             Ok(())
        })
    }
    
    pub fn parse_color(hex: &str) -> LyxalResult<Color> {
        if hex.len() != 7 || !hex.starts_with('#') {
            return Err(LyxalError::InvalidParam("Invalid Hex Color".into()));
        }
        let r = u8::from_str_radix(&hex[1..3], 16).map_err(|_| LyxalError::InvalidParam("Invalid Hex R".into()))?;
        let g = u8::from_str_radix(&hex[3..5], 16).map_err(|_| LyxalError::InvalidParam("Invalid Hex G".into()))?;
        let b = u8::from_str_radix(&hex[5..7], 16).map_err(|_| LyxalError::InvalidParam("Invalid Hex B".into()))?;
        
        // tiny-skia 0.11 Color uses floats [0.0, 1.0]
        Color::from_rgba(
            r as f32 / 255.0,
            g as f32 / 255.0,
            b as f32 / 255.0,
            1.0
        ).ok_or(LyxalError::InternalError("Invalid Color creation".into()))
    }

    pub fn create_paint_from_style(style: &FillStyle, bbox: (f32, f32, f32, f32)) -> LyxalResult<Paint<'static>> {
        let (x, y, w, h) = bbox;
        let mut paint = Paint::default();
        paint.anti_alias = true;
        
        match style {
            FillStyle::Solid { color } => {
                paint.set_color(Self::parse_color(color)?);
            },
            FillStyle::LinearGradient { start, end, stops } => {
                let p_start = Point::from_xy(x + start.0 * w, y + start.1 * h);
                let p_end = Point::from_xy(x + end.0 * w, y + end.1 * h);
                
                let skia_stops: Vec<SkiaStop> = stops.iter().map(|s| {
                     let c = Self::parse_color(&s.color).unwrap_or(Color::BLACK);
                     SkiaStop::new(s.offset.clamp(0.0, 1.0), c)
                }).collect();
                
                paint.shader = LinearGradient::new(
                    p_start, p_end, 
                    skia_stops, 
                    SpreadMode::Pad, 
                    Transform::identity()
                ).ok_or(LyxalError::InvalidParam("Invalid Linear Gradient".into()))?;
            },
            FillStyle::RadialGradient { center, radius, stops } => {
                let p_center = Point::from_xy(x + center.0 * w, y + center.1 * h);
                // Radius relative to what? usually max dimension or width?
                // Let's use Width for radius normalization for now, or average?
                // Standard CSS is often width/height axis specific (ellipse). 
                // Here radius is scalar. Let's multiply by w.
                let abs_radius = radius * w; // Simplification
                
                 let skia_stops: Vec<SkiaStop> = stops.iter().map(|s| {
                     let c = Self::parse_color(&s.color).unwrap_or(Color::BLACK);
                     SkiaStop::new(s.offset.clamp(0.0, 1.0), c)
                }).collect();
                
                paint.shader = RadialGradient::new(
                    p_center, p_center, // Focal point = Center
                    abs_radius, 
                    skia_stops, 
                    SpreadMode::Pad, 
                    Transform::identity()
                ).ok_or(LyxalError::InvalidParam("Invalid Radial Gradient".into()))?;
            }
        }
        Ok(paint)
    }

    pub fn shape_rect(&mut self, x: f32, y: f32, w: f32, h: f32, fill: Option<&FillStyle>, stroke: Option<&FillStyle>, stroke_width: f32, transform: Option<Transform>) -> LyxalResult<()> {
        self.apply_skia_draw(|pixmap| {
            let path = PathBuilder::from_rect(tiny_skia::Rect::from_xywh(x, y, w, h).ok_or(LyxalError::InvalidParam("Invalid Rect coords".into()))?);
            let ts = transform.unwrap_or(Transform::identity());
            let bbox = (x, y, w, h);
            
            if let Some(style) = fill {
                let paint = Self::create_paint_from_style(style, bbox)?;
                pixmap.fill_path(&path, &paint, tiny_skia::FillRule::Winding, ts, None);
            }
            
            if let Some(style) = stroke {
                let paint = Self::create_paint_from_style(style, bbox)?;
                let mut strk = Stroke::default();
                strk.width = stroke_width;
                pixmap.stroke_path(&path, &paint, &strk, ts, None);
            }
            Ok(())
        })
    }
    
    pub fn shape_circle(&mut self, cx: f32, cy: f32, radius: f32, fill: Option<&FillStyle>, stroke: Option<&FillStyle>, stroke_width: f32, transform: Option<Transform>) -> LyxalResult<()> {
        self.apply_skia_draw(|pixmap| {
             let path = PathBuilder::from_circle(cx, cy, radius).ok_or(LyxalError::InternalError("Failed to create circle path".into()))?;
             let ts = transform.unwrap_or(Transform::identity());
             // BBox for Gradient mapping
             let bbox = (cx - radius, cy - radius, radius * 2.0, radius * 2.0);

             if let Some(style) = fill {
                let paint = Self::create_paint_from_style(style, bbox)?;
                pixmap.fill_path(&path, &paint, tiny_skia::FillRule::Winding, ts, None);
            }
            
            if let Some(style) = stroke {
                let paint = Self::create_paint_from_style(style, bbox)?;
                let mut strk = Stroke::default();
                strk.width = stroke_width;
                pixmap.stroke_path(&path, &paint, &strk, ts, None);
            }
             Ok(())
        })
    }

    pub fn shape_line(&mut self, x1: f32, y1: f32, x2: f32, y2: f32, stroke_hex: &str, stroke_width: f32, transform: Option<Transform>) -> LyxalResult<()> {
        self.apply_skia_draw(|pixmap| {
            let mut pb = PathBuilder::new();
            pb.move_to(x1, y1);
            pb.line_to(x2, y2);
            let path = pb.finish().ok_or(LyxalError::InternalError("Empty Line Path".into()))?;
            let ts = transform.unwrap_or(Transform::identity());
            
            let mut paint = Paint::default();
            paint.set_color(Self::parse_color(stroke_hex)?);
            let mut strk = Stroke::default();
            strk.width = stroke_width;
             // Round cap for smoother lines usually
            strk.line_cap = LineCap::Round;
            
            pixmap.stroke_path(&path, &paint, &strk, ts, None);
            Ok(())
        })
    }

    pub fn shape_arrow(&mut self, x1: f32, y1: f32, x2: f32, y2: f32, stroke_hex: &str, stroke_width: f32, head_size: f32, transform: Option<Transform>) -> LyxalResult<()> {
         self.apply_skia_draw(|pixmap| {
            let color = Self::parse_color(stroke_hex)?;
            let mut paint = Paint::default();
            paint.set_color(color);
            let mut strk = Stroke::default();
            strk.width = stroke_width;
            strk.line_cap = LineCap::Round;
            let ts = transform.unwrap_or(Transform::identity());
            
            // Draw Main Line
            let mut pb = PathBuilder::new();
            pb.move_to(x1, y1);
            pb.line_to(x2, y2);
            if let Some(path) = pb.finish() {
                 pixmap.stroke_path(&path, &paint, &strk, ts, None);
            }
            
            // Calculate Arrow Head
            let dx = x2 - x1;
            let dy = y2 - y1;
            let len = (dx*dx + dy*dy).sqrt();
            if len > 0.0 {
                // Unit vector
                let ux = dx / len;
                let uy = dy / len;
                
                // Perpendicular vector
                let px = -uy;
                let py = ux;
                
                // Head points (Backwards from x2,y2)
                let bx = x2 - ux * head_size;
                let by = y2 - uy * head_size;
                
                // Wings
                let wing_offset = head_size * 0.5;
                let p1x = bx + px * wing_offset;
                let p1y = by + py * wing_offset;
                
                let p2x = bx - px * wing_offset;
                let p2y = by - py * wing_offset;
                
                // Draw Triangle filled
                let mut head_pb = PathBuilder::new();
                head_pb.move_to(x2, y2);
                head_pb.line_to(p1x, p1y);
                head_pb.line_to(p2x, p2y);
                head_pb.close();
                if let Some(head_path) = head_pb.finish() {
                     pixmap.fill_path(&head_path, &paint, tiny_skia::FillRule::Winding, ts, None);
                }
            }
             
            Ok(())
        })
    }

    pub fn shape_polygon(&mut self, points: Vec<(f32, f32)>, fill: Option<&FillStyle>, stroke: Option<&FillStyle>, stroke_width: f32, transform: Option<Transform>) -> LyxalResult<()> {
        if points.len() < 3 { return Err(LyxalError::InvalidParam("Poly < 3 pts".into())); }
        
        // Calculate BBox for gradient
        let min_x = points.iter().map(|p| p.0).fold(f32::INFINITY, f32::min);
        let max_x = points.iter().map(|p| p.0).fold(f32::NEG_INFINITY, f32::max);
        let min_y = points.iter().map(|p| p.1).fold(f32::INFINITY, f32::min);
        let max_y = points.iter().map(|p| p.1).fold(f32::NEG_INFINITY, f32::max);
        let bbox = (min_x, min_y, max_x - min_x, max_y - min_y);

        self.apply_skia_draw(|pixmap| {
             let mut pb = PathBuilder::new();
             pb.move_to(points[0].0, points[0].1);
             for i in 1..points.len() {
                 pb.line_to(points[i].0, points[i].1);
             }
             pb.close();
             let path = pb.finish().ok_or(LyxalError::InternalError("Empty Poly Path".into()))?;
             let ts = transform.unwrap_or(Transform::identity());

              if let Some(style) = fill {
                let paint = Self::create_paint_from_style(style, bbox)?;
                pixmap.fill_path(&path, &paint, tiny_skia::FillRule::Winding, ts, None);
            }
            
            if let Some(style) = stroke {
                let paint = Self::create_paint_from_style(style, bbox)?;
                let mut strk = Stroke::default();
                strk.width = stroke_width;
                strk.line_join = LineJoin::Round;
                pixmap.stroke_path(&path, &paint, &strk, ts, None);
            }
             
             Ok(())
        })
    }
    
    pub fn draw_image_transformed(&mut self, source: &LyxalImage, transform: tiny_skia::Transform) -> LyxalResult<()> {
        self.apply_skia_draw(|dest_pixmap| {
            // Source Pixmap
            // We need to access source's buffer.
            // Problem: source.with_inner would lock source.
            // But we are already inside apply_skia_draw which locks dest.
            // If dest == source, deadlock.
            // But here source is a clone() from pipeline, so different Arc/Mutex.
            
            source.with_inner(|src_img| {
                 let src_rgba = src_img.to_rgba8();
                 
                 // How to draw DynamicImage onto Pixmap (dest)?
                 // tiny-skia's draw_pixmap takes a PixmapRef. 
                 // We need to convert src_rgba to PixmapRef.
                 // Pixmap::from_vec or similar? 
                 // PixmapRef::from_bytes needs slice.
                 
                 let src_data = src_rgba.as_raw();
                 let src_pixmap = tiny_skia::PixmapRef::from_bytes(src_data, src_rgba.width(), src_rgba.height())
                      .ok_or(LyxalError::InternalError("Src pixmap create fail".into()))?;
                 
                 // Draw
                 dest_pixmap.draw_pixmap(0, 0, src_pixmap, &PixmapPaint::default(), transform, None);
                 
                 Ok(())
            })?;
            
            Ok(())
        })
    }
}
