use crate::errors::TextResult;
use crate::metrics::TextMetrics;
use crate::layout::{TextLayout, LayoutConfig, TextAlign, PositionedGlyph, LineMetric};
use crate::path::PathGeometry;
use crate::run::{TextRun, TextStyle, FontStyle};
use cosmic_text::{Attrs, Buffer, Family, FontSystem, Metrics, Shaping, Style, Weight, Align};

use crate::env::TextEnvironment;
use std::sync::{Arc, Mutex};

pub struct Shaper {
    font_system: Arc<Mutex<FontSystem>>,
}

impl Shaper {
    pub fn new(env: &TextEnvironment) -> Self {
        Self { font_system: env.font_system.clone() }
    }


    pub fn measure(&mut self, runs: &[TextRun]) -> TextResult<TextMetrics> {
        self.measure_internal(runs)
    }

    fn measure_internal(&mut self, runs: &[TextRun]) -> TextResult<TextMetrics> {
        let mut font_system = self.font_system.lock().unwrap();
        let mut buffer = Buffer::new(&mut *font_system, Metrics::new(24.0, 30.0));
        buffer.set_size(&mut *font_system, 10000.0, 10000.0);
        
        let spans = runs.iter().map(|run| {
            (run.text.as_str(), Self::map_style(&run.style))
        });
        
        buffer.set_rich_text(&mut *font_system, spans, Attrs::new(), Shaping::Advanced);
        buffer.shape_until_scroll(&mut *font_system, true);


        let mut width: f32 = 0.0;
        let mut height: f32 = 0.0;
        
        for run in buffer.layout_runs() {
            width = width.max(run.line_w);
            height += 30.0; // Fallback
        }
        
        if height == 0.0 && !runs.is_empty() { height = 30.0; }

        Ok(TextMetrics {
            width,
            height,
            line_height: 30.0,
            baseline: 0.0,
            ascender: 0.0,
            descender: 0.0,
        })
    }

    pub fn layout_text(&mut self, runs: &[TextRun], config: LayoutConfig) -> TextResult<TextLayout> {
        let mut font_system = self.font_system.lock().unwrap();
        let mut buffer = Buffer::new(&mut *font_system, Metrics::new(24.0, 30.0));
        
        let width_constraint = config.max_width.unwrap_or(10000.0);
        buffer.set_size(&mut *font_system, width_constraint, 10000.0);
        
        let spans = runs.iter().map(|run| {
            (run.text.as_str(), Self::map_style(&run.style))
        });
        
        buffer.set_rich_text(&mut *font_system, spans, Attrs::new(), Shaping::Advanced);
        
        // Apply Alignment
        let cosmic_align = match config.align {
            TextAlign::Left => Align::Left,
            TextAlign::Center => Align::Center,
            TextAlign::Right => Align::Right,
            TextAlign::Justify => Align::Justified,
        };
        
        for line in buffer.lines.iter_mut() {
            line.set_align(Some(cosmic_align));
        }
        
        buffer.shape_until_scroll(&mut *font_system, true);
        
        let mut lines_out = Vec::new();
        let mut glyphs_out = Vec::new();
        let mut total_h: f32 = 0.0;
        let mut max_w: f32 = 0.0;
        
        for run in buffer.layout_runs() {
            max_w = max_w.max(run.line_w);
            let line_height = 30.0; // Fallback to buffer metrics
            let line_y = run.line_y;
            
            total_h = total_h.max(line_y + line_height);
            
            lines_out.push(LineMetric {
                y: line_y,
                height: line_height,
                width: run.line_w,
                start_index: 0,
                end_index: 0, 
            });
            
            for glyph in run.glyphs {
                glyphs_out.push(PositionedGlyph {
                    glyph_id: glyph.glyph_id as u32,
                    x: glyph.x, 
                    y: line_y + glyph.y, 
                    w: glyph.w,
                    h: line_height,
                    rotation: 0.0, // Standard layout has no rotation
                });
            }
        }
        
        Ok(TextLayout {
            width: max_w,
            height: total_h,
            lines: lines_out,
            glyphs: glyphs_out,
        })
    }
    
    pub fn layout_text_on_path(&mut self, runs: &[TextRun], path: &PathGeometry) -> TextResult<TextLayout> {
        // 1. Linear Layout (Infinite width, Left Align to get pure advances)
        let config = LayoutConfig {
            max_width: None,
            align: TextAlign::Left,
        };
        
        let linear_layout = self.layout_text(runs, config)?;
        
        // 2. Map to Path
        let mut curved_glyphs = Vec::new();
        
        for glyph in linear_layout.glyphs {
            let dist = glyph.x;
            let point = path.get_point(dist);
            
            curved_glyphs.push(PositionedGlyph {
                glyph_id: glyph.glyph_id,
                x: point.x,
                y: point.y,
                w: glyph.w,
                h: glyph.h,
                rotation: point.rotation,
            });
        }
        
        Ok(TextLayout {
            width: linear_layout.width,
            height: linear_layout.height, 
            lines: linear_layout.lines,
            glyphs: curved_glyphs,
        })
    }
    
    // Static function to avoid borrowing self
    fn map_style<'a>(style: &'a TextStyle) -> Attrs<'a> {
        let weight = Weight(style.font_weight);
        let font_style = match style.font_style {
            FontStyle::Normal => Style::Normal,
            FontStyle::Italic => Style::Italic,
            FontStyle::Oblique => Style::Oblique,
        };
        
        let family = match style.font_family.as_str() {
             "Serif" => Family::Serif,
             "Sans Serif" => Family::SansSerif,
             "Monospace" => Family::Monospace,
             name => Family::Name(name),
        };
        
        Attrs::new()
             .family(family)
             .weight(weight)
             .style(font_style)
    }
}
