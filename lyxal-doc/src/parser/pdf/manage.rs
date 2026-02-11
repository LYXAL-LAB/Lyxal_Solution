//! PDF content stream parsing and text extraction

use lopdf::{Document, Object};
use std::collections::HashMap;

use super::model::{
    FillRule, PdfElement, PdfImage, PdfPath, PdfPathOp, PdfTextElement, PdfTextRenderingMode, PdfTextLine,
    PdfClipPath, PdfClipRule, PdfClipStack, PdfTransparency, PdfBlendMode, PdfMetadata, PdfPage, PdfDocument,
};
use crate::parser::pdf::common::{PdfBBox, PdfRgba, PdfColorSpace};
use super::image_filters::{decode_image_stream, decode_image_data};
use super::fonts::{self, FontData};

const DEFAULT_LINE_WIDTH: f32 = 500.0;

#[derive(Clone)]
struct TextState {
    tm: [f32; 6],
    font_size: f32,
    rendering_mode: PdfTextRenderingMode,
    font: Option<FontData>,
}

#[derive(Clone)]
struct GraphicsState {
    stroke_color: PdfRgba,
    fill_color: PdfRgba,
    stroke_color_space: PdfColorSpace,
    fill_color_space: PdfColorSpace,
    line_width: f32,
    clip_stack: Vec<PdfClipPath>,
    pending_clip: Option<PdfClipPath>,
    transparency: PdfTransparency,
}

#[derive(Clone)]
struct PathState {
    ops: Vec<PdfPathOp>,
}

impl GraphicsState {
    fn new() -> Self {
        Self {
            stroke_color: PdfRgba::default(),
            fill_color: PdfRgba::default(),
            stroke_color_space: PdfColorSpace::DeviceGray,
            fill_color_space: PdfColorSpace::DeviceGray,
            line_width: 1.0,
            clip_stack: Vec::new(),
            pending_clip: None,
            transparency: PdfTransparency::default(),
        }
    }

    fn consume_path_and_apply_clip(&mut self) {
        if let Some(clip) = self.pending_clip.take() {
            self.clip_stack.push(clip);
        }
    }

    fn get_clip_stack(&self) -> Option<PdfClipStack> {
        if self.clip_stack.is_empty() {
            None
        } else {
            Some(PdfClipStack {
                clips: self.clip_stack.clone(),
            })
        }
    }
}

impl PathState {
    fn new() -> Self {
        Self {
            ops: Vec::new(),
        }
    }
}

impl TextState {
    fn new() -> Self {
        Self {
            tm: [1.0, 0.0, 0.0, 1.0, 0.0, 0.0],
            font_size: 12.0,
            rendering_mode: PdfTextRenderingMode::Fill,
            font: None,
        }
    }

    fn set_tm(&mut self, a: f32, b: f32, c: f32, d: f32, e: f32, f: f32) {
        self.tm = [a, b, c, d, e, f];
    }

    fn translate(&mut self, tx: f32, ty: f32) {
        self.tm[4] += tx;
        self.tm[5] += ty;
    }

    fn pos(&self) -> (f32, f32) {
        (self.tm[4], self.tm[5])
    }
}

/// Parse text elements from a page
pub fn parse_text_elements(doc: &Document, page_index: usize) -> Vec<PdfElement> {
    let mut out = Vec::new();
    let pages = doc.get_pages();
    let page_id = match pages.get(&(page_index as u32 + 1)) {
        Some(id) => *id,
        None => return out,
    };

    let fonts = load_fonts(doc, page_id);
    let Ok(raw) = doc.get_and_decode_page_content(page_id) else {
        return out;
    };

    let mut ts = TextState::new();
    let mut ps = PathState::new();
    let mut gs = GraphicsState::new();

    let mut in_inline_image = false;
    let mut after_id = false;
    let mut inline_dict = HashMap::new();
    let mut inline_data = Vec::new();

    for op in raw.operations {
        if in_inline_image {
            match op.operator.as_str() {
                "ID" => {
                    after_id = true;
                    if !op.operands.is_empty() {
                         if let Ok(data) = op.operands[0].as_str() {
                             inline_data = data.to_vec();
                         }
                    }
                }
                "EI" => {
                    if let Some(mut img) = create_inline_image(&inline_dict, &inline_data, &ts, doc) {
                         img.clip = gs.get_clip_stack();
                         img.transparency = gs.transparency.clone();
                         out.push(PdfElement::Image(img));
                    }
                    in_inline_image = false;
                    after_id = false;
                    inline_dict.clear();
                    inline_data.clear();
                }
                _ => {
                    if !after_id {
                        let key = op.operator.clone();
                        if let Some(val) = op.operands.get(0) {
                            inline_dict.insert(key, val.clone());
                        }
                    }
                }
            }
            continue;
        }

        match op.operator.as_str() {
            "BT" => { ts = TextState::new(); }
            "ET" => { ts = TextState::new(); }
            "Tm" => {
                if op.operands.len() == 6 {
                    ts.set_tm(
                        as_f32(&op.operands[0]),
                        as_f32(&op.operands[1]),
                        as_f32(&op.operands[2]),
                        as_f32(&op.operands[3]),
                        as_f32(&op.operands[4]),
                        as_f32(&op.operands[5]),
                    );
                }
            }
            "Td" | "TD" => {
                if op.operands.len() == 2 {
                    ts.translate(as_f32(&op.operands[0]), as_f32(&op.operands[1]));
                }
            }
            "Tf" => {
                if op.operands.len() == 2 {
                    let font_name = op.operands[0]
                        .as_name()
                        .ok()
                        .map(|s| String::from_utf8_lossy(s).into_owned());
                    ts.font_size = as_f32(&op.operands[1]);
                    ts.font = font_name
                        .as_deref()
                        .and_then(|name| fonts.get(name).cloned());
                }
            }
            "Tr" => {
                if let Some(mode) = op.operands.get(0).and_then(|o| o.as_i64().ok()) {
                    ts.rendering_mode = match mode {
                        0 => PdfTextRenderingMode::Fill,
                        1 => PdfTextRenderingMode::Stroke,
                        2 => PdfTextRenderingMode::FillStroke,
                        3 => PdfTextRenderingMode::Invisible,
                        4 => PdfTextRenderingMode::FillClip,
                        5 => PdfTextRenderingMode::StrokeClip,
                        6 => PdfTextRenderingMode::FillStrokeClip,
                        7 => PdfTextRenderingMode::Clip,
                        _ => PdfTextRenderingMode::Fill,
                    };
                }
            }
            "Tj" => {
                if let Some(txt) = decode_text(op.operands.get(0), &ts) {
                    let (x, y) = ts.pos();
                    out.push(PdfElement::Text(PdfTextElement {
                        content: txt,
                        x,
                        y,
                        font_size: ts.font_size,
                        rendering_mode: ts.rendering_mode,
                        fill_color: gs.fill_color.clone(),
                        stroke_color: if matches!(ts.rendering_mode, PdfTextRenderingMode::Stroke | PdfTextRenderingMode::FillStroke | PdfTextRenderingMode::StrokeClip | PdfTextRenderingMode::FillStrokeClip) { Some(gs.stroke_color.clone()) } else { None },
                        stroke_width: if matches!(ts.rendering_mode, PdfTextRenderingMode::Stroke | PdfTextRenderingMode::FillStroke | PdfTextRenderingMode::StrokeClip | PdfTextRenderingMode::FillStrokeClip) { Some(gs.line_width) } else { None },
                        clip: gs.get_clip_stack(),
                        transparency: gs.transparency.clone(),
                    }));
                    let adv = advance_text(op.operands.get(0), &ts);
                    ts.translate(adv, 0.0);
                }
            }
            "TJ" => {
                if let Some(txt) = decode_array_text(op.operands.get(0), &ts) {
                    let (x, y) = ts.pos();
                    out.push(PdfElement::Text(PdfTextElement {
                        content: txt,
                        x,
                        y,
                        font_size: ts.font_size,
                        rendering_mode: ts.rendering_mode,
                        fill_color: gs.fill_color.clone(),
                        stroke_color: if matches!(ts.rendering_mode, PdfTextRenderingMode::Stroke | PdfTextRenderingMode::FillStroke | PdfTextRenderingMode::StrokeClip | PdfTextRenderingMode::FillStrokeClip) { Some(gs.stroke_color.clone()) } else { None },
                        stroke_width: if matches!(ts.rendering_mode, PdfTextRenderingMode::Stroke | PdfTextRenderingMode::FillStroke | PdfTextRenderingMode::StrokeClip | PdfTextRenderingMode::FillStrokeClip) { Some(gs.line_width) } else { None },
                        clip: gs.get_clip_stack(),
                        transparency: gs.transparency.clone(),
                    }));
                    let adv = advance_array(op.operands.get(0), &ts);
                    ts.translate(adv, 0.0);
                }
            }
            "Do" => {
                if op.operands.len() == 1 {
                    if let Ok(name) = op.operands[0].as_name() {
                        if let Some(mut image) = resolve_xobject_image(doc, page_id, name, &ts) {
                            image.clip = gs.get_clip_stack();
                            image.transparency = gs.transparency.clone();
                            out.push(PdfElement::Image(image));
                        }
                    }
                }
            }
            "BI" => {
                in_inline_image = true;
                inline_dict.clear();
                inline_data.clear();
                after_id = false;
            }
            "m" => {
                if op.operands.len() == 2 {
                    let x = as_f32(&op.operands[0]);
                    let y = as_f32(&op.operands[1]);
                    let (tx, ty) = transform(x, y, &ts.tm);
                    ps.ops.push(PdfPathOp::MoveTo { x: tx, y: ty });
                }
            }
            "l" => {
                if op.operands.len() == 2 {
                    let x = as_f32(&op.operands[0]);
                    let y = as_f32(&op.operands[1]);
                    let (tx, ty) = transform(x, y, &ts.tm);
                    ps.ops.push(PdfPathOp::LineTo { x: tx, y: ty });
                }
            }
            "c" => {
                if op.operands.len() == 6 {
                    let x1 = as_f32(&op.operands[0]);
                    let y1 = as_f32(&op.operands[1]);
                    let x2 = as_f32(&op.operands[2]);
                    let y2 = as_f32(&op.operands[3]);
                    let x3 = as_f32(&op.operands[4]);
                    let y3 = as_f32(&op.operands[5]);
                    let (tx1, ty1) = transform(x1, y1, &ts.tm);
                    let (tx2, ty2) = transform(x2, y2, &ts.tm);
                    let (tx3, ty3) = transform(x3, y3, &ts.tm);
                    ps.ops.push(PdfPathOp::CurveTo {
                        x1: tx1, y1: ty1,
                        x2: tx2, y2: ty2,
                        x3: tx3, y3: ty3,
                    });
                }
            }
            "re" => {
                if op.operands.len() == 4 {
                    let x = as_f32(&op.operands[0]);
                    let y = as_f32(&op.operands[1]);
                    let w = as_f32(&op.operands[2]);
                    let h = as_f32(&op.operands[3]);
                    let (tx, ty) = transform(x, y, &ts.tm);
                    let tw = w * ts.tm[0];
                    let th = h * ts.tm[3];
                    ps.ops.push(PdfPathOp::Rectangle {
                        x: tx, y: ty, width: tw, height: th,
                    });
                }
            }
            "h" => { ps.ops.push(PdfPathOp::ClosePath); }
            "gs" => {
                if let Some(name) = op.operands.get(0).and_then(|o| o.as_name().ok()) {
                    if let Some(ext_gstate) = resolve_ext_gstate(doc, page_id, name) {
                        apply_ext_gstate(&mut gs, &ext_gstate);
                    }
                }
            }
            "W" | "W*" => {
                let rule = if op.operator.ends_with('*') {
                    PdfClipRule::EvenOdd
                } else {
                    PdfClipRule::NonZero
                };
                
                let clip_path = PdfPath {
                    ops: ps.ops.clone(),
                    stroke_color: PdfRgba::default(),
                    fill_color: PdfRgba::default(),
                    line_width: 0.0,
                    fill_rule: match rule {
                        PdfClipRule::NonZero => FillRule::NonZero,
                        PdfClipRule::EvenOdd => FillRule::EvenOdd,
                    },
                    bbox: calculate_bbox(&ps.ops, 0.0, false),
                    clip: None,
                    transparency: gs.transparency.clone(),
                };
                
                gs.pending_clip = Some(PdfClipPath { path: clip_path, rule });
            }
            "n" => {
                gs.consume_path_and_apply_clip();
                ps.ops.clear();
            }
            "S" | "s" => {
                let current_clip = gs.get_clip_stack();
                gs.consume_path_and_apply_clip();
                
                if op.operator == "s" { ps.ops.push(PdfPathOp::ClosePath); }
                let bbox = calculate_bbox(&ps.ops, gs.line_width, true);
                out.push(PdfElement::Path(PdfPath {
                    ops: ps.ops.clone(),
                    stroke_color: gs.stroke_color.clone(),
                    fill_color: PdfRgba::default(),
                    line_width: gs.line_width,
                    fill_rule: FillRule::NonZero,
                    bbox,
                    clip: current_clip,
                    transparency: gs.transparency.clone(),
                }));
                ps.ops.clear();
            }
            "f" | "F" | "f*" => {
                let current_clip = gs.get_clip_stack();
                gs.consume_path_and_apply_clip();
                
                let rule = if op.operator == "f*" { FillRule::EvenOdd } else { FillRule::NonZero };
                let bbox = calculate_bbox(&ps.ops, gs.line_width, false);
                out.push(PdfElement::Path(PdfPath {
                    ops: ps.ops.clone(),
                    stroke_color: PdfRgba::default(),
                    fill_color: gs.fill_color.clone(),
                    line_width: gs.line_width,
                    fill_rule: rule,
                    bbox,
                    clip: current_clip,
                    transparency: gs.transparency.clone(),
                }));
                ps.ops.clear();
            }
            "B" | "B*" | "b" | "b*" => {
                let current_clip = gs.get_clip_stack();
                gs.consume_path_and_apply_clip();
                
                let rule = if op.operator.ends_with('*') { FillRule::EvenOdd } else { FillRule::NonZero };
                let close = op.operator.starts_with('b');
                if close { ps.ops.push(PdfPathOp::ClosePath); }
                let bbox = calculate_bbox(&ps.ops, gs.line_width, true);
                out.push(PdfElement::Path(PdfPath {
                    ops: ps.ops.clone(),
                    stroke_color: gs.stroke_color.clone(),
                    fill_color: gs.fill_color.clone(),
                    line_width: gs.line_width,
                    fill_rule: rule,
                    bbox,
                    clip: current_clip,
                    transparency: gs.transparency.clone(),
                }));
                ps.ops.clear();
            }
            "w" => {
                if let Some(w) = op.operands.get(0) { gs.line_width = as_f32(w); }
            }
            "RG" => {
                if op.operands.len() == 3 {
                    let r = as_f32(&op.operands[0]);
                    let g = as_f32(&op.operands[1]);
                    let b = as_f32(&op.operands[2]);
                    gs.stroke_color = PdfRgba { r: r.clamp(0.0, 1.0), g: g.clamp(0.0, 1.0), b: b.clamp(0.0, 1.0), a: 1.0 };
                    gs.stroke_color_space = PdfColorSpace::DeviceRGB;
                }
            }
            "rg" => {
                if op.operands.len() == 3 {
                    let r = as_f32(&op.operands[0]);
                    let g = as_f32(&op.operands[1]);
                    let b = as_f32(&op.operands[2]);
                    gs.fill_color = PdfRgba { r: r.clamp(0.0, 1.0), g: g.clamp(0.0, 1.0), b: b.clamp(0.0, 1.0), a: 1.0 };
                    gs.fill_color_space = PdfColorSpace::DeviceRGB;
                }
            }
            "K" => {
                if op.operands.len() == 4 {
                    let c = as_f32(&op.operands[0]);
                    let m = as_f32(&op.operands[1]);
                    let y = as_f32(&op.operands[2]);
                    let k = as_f32(&op.operands[3]);
                    gs.stroke_color = cmyk_to_rgb(c, m, y, k);
                    gs.stroke_color_space = PdfColorSpace::DeviceCMYK;
                }
            }
            "k" => {
                if op.operands.len() == 4 {
                    let c = as_f32(&op.operands[0]);
                    let m = as_f32(&op.operands[1]);
                    let y = as_f32(&op.operands[2]);
                    let k = as_f32(&op.operands[3]);
                    gs.fill_color = cmyk_to_rgb(c, m, y, k);
                    gs.fill_color_space = PdfColorSpace::DeviceCMYK;
                }
            }
            "G" => {
                if let Some(g) = op.operands.get(0) {
                    let val = as_f32(g).clamp(0.0, 1.0);
                    gs.stroke_color = PdfRgba { r: val, g: val, b: val, a: 1.0 };
                    gs.stroke_color_space = PdfColorSpace::DeviceGray;
                }
            }
            "g" => {
                if let Some(g) = op.operands.get(0) {
                    let val = as_f32(g).clamp(0.0, 1.0);
                    gs.fill_color = PdfRgba { r: val, g: val, b: val, a: 1.0 };
                    gs.fill_color_space = PdfColorSpace::DeviceGray;
                }
            }
            "CS" => {
                if let Some(name) = op.operands.get(0).and_then(|o| o.as_name().ok()) {
                     gs.stroke_color_space = parse_color_space(name, doc, page_id);
                }
            }
            "cs" => {
                if let Some(name) = op.operands.get(0).and_then(|o| o.as_name().ok()) {
                     gs.fill_color_space = parse_color_space(name, doc, page_id);
                }
            }
            "SC" | "SCN" => {
                 set_color_from_operands(&op.operands, &gs.stroke_color_space, &mut gs.stroke_color);
            }
            "sc" | "scn" => {
                 set_color_from_operands(&op.operands, &gs.fill_color_space, &mut gs.fill_color);
            }
            _ => {}
        }
    }

    out
}

fn cmyk_to_rgb(c: f32, m: f32, y: f32, k: f32) -> PdfRgba {
    let r = 1.0 - (c + k).min(1.0);
    let g = 1.0 - (m + k).min(1.0);
    let b = 1.0 - (y + k).min(1.0);
    PdfRgba { r: r.clamp(0.0, 1.0), g: g.clamp(0.0, 1.0), b: b.clamp(0.0, 1.0), a: 1.0 }
}

fn parse_color_space(name: &[u8], doc: &Document, page_id: (u32, u16)) -> PdfColorSpace {
    match name {
        b"DeviceRGB" => PdfColorSpace::DeviceRGB,
        b"DeviceCMYK" => PdfColorSpace::DeviceCMYK,
        b"DeviceGray" => PdfColorSpace::DeviceGray,
        _ => {
             if let Ok((res_opt, _)) = doc.get_page_resources(page_id) {
                 if let Some(resources) = res_opt {
                     if let Ok(cs_dict) = resources.get(b"ColorSpace").and_then(|o| o.as_dict()) {
                         if let Ok(cs_obj) = cs_dict.get(name) {
                             return resolve_color_space_resource(cs_obj, doc);
                         }
                     }
                 }
             }
             PdfColorSpace::Other(String::from_utf8_lossy(name).into_owned())
        }
    }
}

fn resolve_color_space_resource(obj: &Object, doc: &Document) -> PdfColorSpace {
    match obj {
        Object::Name(n) => parse_color_space(n, doc, (0,0)),
        Object::Array(arr) => {
             if let Some(Object::Name(base)) = arr.get(0) {
                 match base.as_slice() {
                     b"ICCBased" => {
                         if let Some(stream_ref) = arr.get(1) {
                             if let Ok(stream) = doc.get_object(stream_ref.as_reference().unwrap_or((0,0))) {
                                  if let Object::Stream(s) = stream {
                                      if let Ok(n) = s.dict.get(b"N").and_then(|o| o.as_i64()) {
                                          return PdfColorSpace::ICCBased { n: n as u8 };
                                      }
                                  }
                             }
                         }
                         PdfColorSpace::ICCBased { n: 0 }
                     }
                     b"Lab" => PdfColorSpace::Lab,
                     _ => PdfColorSpace::Other(String::from_utf8_lossy(base).into_owned())
                 }
             } else {
                 PdfColorSpace::Other("UnknownArray".to_string())
             }
        }
        Object::Reference(r) => {
             if let Ok(o) = doc.get_object(*r) {
                 resolve_color_space_resource(o, doc)
             } else {
                 PdfColorSpace::Other("InvalidRef".to_string())
             }
        }
        _ => PdfColorSpace::Other("UnknownType".to_string())
    }
}

fn set_color_from_operands(operands: &[Object], cs: &PdfColorSpace, color: &mut PdfRgba) {
    match cs {
        PdfColorSpace::DeviceGray => {
            if let Some(g) = operands.get(0) {
                let val = as_f32(g).clamp(0.0, 1.0);
                *color = PdfRgba { r: val, g: val, b: val, a: 1.0 };
            }
        }
        PdfColorSpace::DeviceRGB => {
            if operands.len() >= 3 {
                let r = as_f32(&operands[0]).clamp(0.0, 1.0);
                let g = as_f32(&operands[1]).clamp(0.0, 1.0);
                let b = as_f32(&operands[2]).clamp(0.0, 1.0);
                *color = PdfRgba { r, g, b, a: 1.0 };
            }
        }
        PdfColorSpace::DeviceCMYK => {
            if operands.len() >= 4 {
                let c = as_f32(&operands[0]);
                let m = as_f32(&operands[1]);
                let y = as_f32(&operands[2]);
                let k = as_f32(&operands[3]);
                *color = cmyk_to_rgb(c, m, y, k);
            }
        }
        PdfColorSpace::Lab => {
            if operands.len() >= 3 {
                 let l = as_f32(&operands[0]);
                 let val = (l / 100.0).clamp(0.0, 1.0);
                 *color = PdfRgba { r: val, g: val, b: val, a: 1.0 };
            }
        }
        PdfColorSpace::ICCBased { n } => {
            if *n == 1 && !operands.is_empty() {
                let val = as_f32(&operands[0]).clamp(0.0, 1.0);
                *color = PdfRgba { r: val, g: val, b: val, a: 1.0 };
            } else if *n == 3 && operands.len() >= 3 {
                let r = as_f32(&operands[0]).clamp(0.0, 1.0);
                let g = as_f32(&operands[1]).clamp(0.0, 1.0);
                let b = as_f32(&operands[2]).clamp(0.0, 1.0);
                *color = PdfRgba { r, g, b, a: 1.0 };
            } else if *n == 4 && operands.len() >= 4 {
                let c = as_f32(&operands[0]);
                let m = as_f32(&operands[1]);
                let y = as_f32(&operands[2]);
                let k = as_f32(&operands[3]);
                *color = cmyk_to_rgb(c, m, y, k);
            } else {
                 *color = PdfRgba { r: 0.0, g: 0.0, b: 0.0, a: 1.0 };
            }
        }
        _ => {}
    }
}

fn calculate_bbox(ops: &[PdfPathOp], line_width: f32, stroked: bool) -> PdfBBox {
    let mut min_x = f32::INFINITY;
    let mut min_y = f32::INFINITY;
    let mut max_x = f32::NEG_INFINITY;
    let mut max_y = f32::NEG_INFINITY;

    if ops.is_empty() {
        return PdfBBox { min_x: 0.0, min_y: 0.0, max_x: 0.0, max_y: 0.0 };
    }

    for op in ops {
        match op {
            PdfPathOp::MoveTo { x, y } | PdfPathOp::LineTo { x, y } => {
                min_x = min_x.min(*x);
                min_y = min_y.min(*y);
                max_x = max_x.max(*x);
                max_y = max_y.max(*y);
            }
            PdfPathOp::CurveTo { x1, y1, x2, y2, x3, y3 } => {
                min_x = min_x.min(*x1).min(*x2).min(*x3);
                min_y = min_y.min(*y1).min(*y2).min(*y3);
                max_x = max_x.max(*x1).max(*x2).max(*x3);
                max_y = max_y.max(*y1).max(*y2).max(*y3);
            }
            PdfPathOp::Rectangle { x, y, width, height } => {
                let rx = *x;
                let ry = *y;
                let x_end = rx + *width;
                let y_end = ry + *height;
                
                let r_min_x = rx.min(x_end);
                let r_max_x = rx.max(x_end);
                let r_min_y = ry.min(y_end);
                let r_max_y = ry.max(y_end);

                min_x = min_x.min(r_min_x);
                min_y = min_y.min(r_min_y);
                max_x = max_x.max(r_max_x);
                max_y = max_y.max(r_max_y);
            }
            PdfPathOp::ClosePath => {}
        }
    }

    if min_x == f32::INFINITY {
         return PdfBBox { min_x: 0.0, min_y: 0.0, max_x: 0.0, max_y: 0.0 };
    }

    if stroked {
        let half_w = line_width / 2.0;
        min_x -= half_w;
        min_y -= half_w;
        max_x += half_w;
        max_y += half_w;
    }

    PdfBBox { min_x, min_y, max_x, max_y }
}

/// Wrapping simple based on fixed width
pub fn wrap_text_elements(elements: &[PdfTextElement]) -> Vec<PdfTextLine> {
    if elements.is_empty() {
        return Vec::new();
    }

    let mut lines = Vec::new();
    let mut current_elems = Vec::new();
    let mut current_width = 0.0;
    let mut current_y = elements[0].y;
    let mut current_max_font_size = elements[0].font_size;

    for elem in elements.iter() {
        let elem_width = estimate_width(elem);
        let overflow = (!current_elems.is_empty() && current_width + elem_width > DEFAULT_LINE_WIDTH)
            || (current_elems.is_empty() && elem_width > DEFAULT_LINE_WIDTH);

        if overflow {
            let mut hyphenated = false;
            if let Some((head, tail)) = hyphenate_to_fit(elem, DEFAULT_LINE_WIDTH - current_width) {
                let head_elem = PdfTextElement {
                    content: head,
                    x: current_width,
                    y: current_y,
                    font_size: elem.font_size,
                    rendering_mode: elem.rendering_mode,
                    fill_color: elem.fill_color.clone(),
                    stroke_color: elem.stroke_color.clone(),
                    stroke_width: elem.stroke_width,
                    clip: elem.clip.clone(),
                    transparency: elem.transparency.clone(),
                };
                let head_width = estimate_width(&head_elem);
                current_max_font_size = current_max_font_size.max(elem.font_size);
                current_width += head_width;
                current_elems.push(head_elem);

                let line_height = current_max_font_size * 1.2;
                lines.push(PdfTextLine {
                    elements: current_elems,
                    width: current_width,
                    y: current_y,
                    line_height,
                });

                current_y += line_height;
                current_max_font_size = elem.font_size;
                current_elems = Vec::new();
                current_width = 0.0;

                let tail_elem = PdfTextElement {
                    content: tail,
                    x: 0.0,
                    y: current_y,
                    font_size: elem.font_size,
                    rendering_mode: elem.rendering_mode,
                    fill_color: elem.fill_color.clone(),
                    stroke_color: elem.stroke_color.clone(),
                    stroke_width: elem.stroke_width,
                    clip: elem.clip.clone(),
                    transparency: elem.transparency.clone(),
                };
                current_width += estimate_width(&tail_elem);
                current_elems.push(tail_elem);
                hyphenated = true;
            }

            if !hyphenated {
                let line_height = current_max_font_size * 1.2;
                lines.push(PdfTextLine {
                    elements: current_elems,
                    width: current_width,
                    y: current_y,
                    line_height,
                });
                current_y += line_height;
                current_max_font_size = elem.font_size;
                current_elems = Vec::new();
                current_width = 0.0;

                let mut placed = elem.clone();
                placed.x = 0.0;
                placed.y = current_y;
                let w = estimate_width(&placed);
                current_width += w;
                current_max_font_size = current_max_font_size.max(placed.font_size);
                current_elems.push(placed);
            }
        } else {
            current_max_font_size = current_max_font_size.max(elem.font_size);
            let mut placed = elem.clone();
            placed.x = current_width;
            placed.y = current_y;
            current_width += elem_width;
            current_elems.push(placed);
        }
    }

    if !current_elems.is_empty() {
        let line_height = current_max_font_size * 1.2;
        lines.push(PdfTextLine {
            elements: current_elems,
            width: current_width,
            y: current_y,
            line_height,
        });
    }

    justify_lines(&mut lines);
    lines
}

fn estimate_width(elem: &PdfTextElement) -> f32 {
    elem.font_size * 0.5 * elem.content.len() as f32
}

fn hyphenate_to_fit(elem: &PdfTextElement, remaining_width: f32) -> Option<(String, String)> {
    let word = elem.content.as_str();
    if word.len() < 5 { return None; }

    let max_chars = ((remaining_width / (elem.font_size * 0.5)).floor() as usize).saturating_sub(1);
    if max_chars < 2 || max_chars >= word.len() { return None; }

    let head = &word[..max_chars];
    let tail = &word[max_chars..];
    Some((format!("{head}-"), tail.to_string()))
}

fn justify_lines(lines: &mut [PdfTextLine]) {
    if lines.len() < 2 { return; }

    for i in 0..lines.len() - 1 {
        let line = &mut lines[i];
        let space_count: usize = line.elements.iter()
            .map(|e| e.content.as_bytes().iter().filter(|b| **b == b' ').count())
            .sum();
        if space_count == 0 { continue; }

        let remaining = DEFAULT_LINE_WIDTH - line.width;
        if remaining <= 0.0 { continue; }
        let extra_per_space = remaining / space_count as f32;

        let mut offset = 0.0;
        for elem in line.elements.iter_mut() {
            elem.x += offset;
            let spaces = elem.content.as_bytes().iter().filter(|b| **b == b' ').count();
            offset += extra_per_space * spaces as f32;
        }

        line.width = DEFAULT_LINE_WIDTH;
    }
}

fn as_f32(obj: &Object) -> f32 {
    match obj {
        Object::Integer(i) => *i as f32,
        Object::Real(r) => *r as f32,
        _ => 0.0,
    }
}

fn advance_text(obj: Option<&Object>, ts: &TextState) -> f32 {
    let bytes_opt = extract_bytes(obj);
    if let Some(bytes) = bytes_opt {
        glyphs_advance(&bytes, ts)
    } else {
        0.0
    }
}

fn advance_array(obj: Option<&Object>, ts: &TextState) -> f32 {
    match obj {
        Some(Object::Array(arr)) => {
            let mut total = 0.0;
            for item in arr {
                match item {
                    Object::Integer(_) | Object::Real(_) => {
                        let adj = as_f32(item);
                        total -= adj * ts.font_size / 1000.0;
                    }
                    _ => {
                        if let Some(b) = extract_bytes(Some(item)) {
                            total += glyphs_advance(&b, ts);
                        }
                    }
                }
            }
            total
        }
        _ => advance_text(obj, ts),
    }
}

fn glyphs_advance(bytes: &[u8], ts: &TextState) -> f32 {
    if let Some(data) = &ts.font {
        let scale = ts.font_size / 1000.0;
        
        let mut total = 0.0;
        let mut i = 0;
        while i < bytes.len() {
            let cid = if data.is_cid && i + 1 < bytes.len() {
                let val = u16::from_be_bytes([bytes[i], bytes[i+1]]);
                i += 2;
                val
            } else {
                let val = bytes[i] as u16;
                i += 1;
                val
            };
            
            let width = data.advances.get(&cid).copied().unwrap_or(data.default_width);
            total += width * scale;
        }
        total
    } else {
        (ts.font_size * 0.5) * bytes.len() as f32
    }
}

fn decode_text(obj: Option<&Object>, ts: &TextState) -> Option<String> {
    let bytes = extract_bytes(obj)?;
    decode_bytes(&bytes, ts)
}

fn decode_array_text(obj: Option<&Object>, ts: &TextState) -> Option<String> {
    match obj {
        Some(Object::Array(arr)) => {
            let mut s = String::new();
            for item in arr {
                match item {
                    Object::String(bytes, _) => {
                        if let Some(part) = decode_bytes(bytes, ts) {
                            s.push_str(&part);
                        }
                    }
                    _ => {}
                }
            }
            Some(s)
        }
        other => decode_text(other, ts),
    }
}

fn extract_bytes(obj: Option<&Object>) -> Option<Vec<u8>> {
    match obj {
        Some(Object::String(bytes, _)) => Some(bytes.clone()),
        Some(other) => other.as_str().ok().map(|b| b.to_vec()),
        None => None,
    }
}

fn decode_bytes(bytes: &[u8], ts: &TextState) -> Option<String> {
    if let Some(font) = &ts.font {
        let mut res = String::new();
        let mut i = 0;
        while i < bytes.len() {
            let code = if font.is_cid && i + 1 < bytes.len() {
                let val = u16::from_be_bytes([bytes[i], bytes[i+1]]) as u32;
                i += 2;
                val
            } else {
                let val = bytes[i] as u32;
                i += 1;
                val
            };
            
            if let Some(uni) = font.to_unicode.get(&code) {
                res.push_str(uni);
            } else {
                if !font.is_cid {
                    res.push(char::from_u32(code).unwrap_or('?'));
                } else {
                    res.push('\u{FFFD}');
                }
            }
        }
        Some(res)
    } else {
        Some(String::from_utf8_lossy(bytes).into_owned())
    }
}

fn load_fonts(doc: &Document, page_id: (u32, u16)) -> HashMap<String, FontData> {
    let mut map = HashMap::new();
    let (res_opt, _) = match doc.get_page_resources(page_id) {
        Ok(r) => r,
        Err(_) => return map,
    };

    let resources: &lopdf::Dictionary = match res_opt {
        Some(r) => r,
        None => return map,
    };

    if let Ok(fonts_obj) = resources.get(b"Font") {
        if let Ok(fonts) = fonts_obj.as_dict() {
            for (name, font_obj) in fonts.iter() {
                let font_dict = match font_obj {
                    Object::Dictionary(d) => Some(d),
                    Object::Reference(r) => doc.get_dictionary(*r).ok(),
                    _ => None,
                };
                
                if let Some(d) = font_dict {
                    if let Some(font_data) = fonts::load_font(doc, d) {
                        map.insert(String::from_utf8_lossy(name).into_owned(), font_data);
                    }
                }
            }
        }
    }
    map
}

fn resolve_ext_gstate(doc: &Document, page_id: (u32, u16), name: &[u8]) -> Option<lopdf::Dictionary> {
    let (res_opt, _) = doc.get_page_resources(page_id).ok()?;
    let resources = res_opt?;
    let ext_gstates = resources.get(b"ExtGState").ok()?.as_dict().ok()?;
    let gs_obj = ext_gstates.get(name).ok()?;
    
    match gs_obj {
        Object::Dictionary(d) => Some(d.clone()),
        Object::Reference(r) => doc.get_dictionary(*r).ok().cloned(),
        _ => None,
    }
}

fn apply_ext_gstate(gs: &mut GraphicsState, dict: &lopdf::Dictionary) {
    if let Ok(obj) = dict.get(b"CA") {
        let ca = match obj {
            Object::Real(f) => Some(*f as f64),
            Object::Integer(i) => Some(*i as f64),
            _ => None,
        };
        if let Some(v) = ca {
            gs.transparency.stroke_alpha = v.clamp(0.0, 1.0) as f32;
        }
    }
    
    if let Ok(obj) = dict.get(b"ca") {
        let ca = match obj {
            Object::Real(f) => Some(*f as f64),
            Object::Integer(i) => Some(*i as f64),
            _ => None,
        };
        if let Some(v) = ca {
            gs.transparency.fill_alpha = v.clamp(0.0, 1.0) as f32;
        }
    }
    
    if let Ok(bm_obj) = dict.get(b"BM") {
        gs.transparency.blend_mode = parse_blend_mode(bm_obj);
    }
}

fn parse_blend_mode(obj: &Object) -> PdfBlendMode {
    let name_to_mode = |name: &[u8]| -> PdfBlendMode {
        match name {
            b"Normal" => PdfBlendMode::Normal,
            b"Multiply" => PdfBlendMode::Multiply,
            b"Screen" => PdfBlendMode::Screen,
            b"Overlay" => PdfBlendMode::Overlay,
            b"Darken" => PdfBlendMode::Darken,
            b"Lighten" => PdfBlendMode::Lighten,
            b"ColorDodge" => PdfBlendMode::ColorDodge,
            b"ColorBurn" => PdfBlendMode::ColorBurn,
            b"HardLight" => PdfBlendMode::HardLight,
            b"SoftLight" => PdfBlendMode::SoftLight,
            b"Difference" => PdfBlendMode::Difference,
            b"Exclusion" => PdfBlendMode::Exclusion,
            b"Hue" => PdfBlendMode::Hue,
            b"Saturation" => PdfBlendMode::Saturation,
            b"Color" => PdfBlendMode::Color,
            b"Luminosity" => PdfBlendMode::Luminosity,
            other => PdfBlendMode::Other(String::from_utf8_lossy(other).into_owned()),
        }
    };

    match obj {
        Object::Name(name) => name_to_mode(name),
        Object::Array(arr) => {
            if let Some(Object::Name(name)) = arr.get(0) {
                name_to_mode(name)
            } else {
                PdfBlendMode::Normal
            }
        },
        _ => PdfBlendMode::Normal,
    }
}

fn resolve_xobject_image(doc: &Document, page_id: (u32, u16), name: &[u8], ts: &TextState) -> Option<PdfImage> {
    let (res_opt, _) = doc.get_page_resources(page_id).ok()?;
    let resources = res_opt?;
    let xobjects = resources.get(b"XObject").ok()?.as_dict().ok()?;
    let xobj_ref = xobjects.get(name).ok()?;
    let xobj = match xobj_ref {
        Object::Reference(r) => doc.get_object(*r).ok()?,
        Object::Stream(s) => return image_from_stream(s, ts, doc),
        _ => return None,
    };

    if let Object::Stream(s) = xobj {
        image_from_stream(s, ts, doc)
    } else {
        None
    }
}

fn image_from_stream(stream: &lopdf::Stream, ts: &TextState, doc: &Document) -> Option<PdfImage> {
    let dict = &stream.dict;
    if dict.get(b"Subtype").ok()?.as_name().ok()? != b"Image" {
        return None;
    }

    let width = dict.get(b"Width").ok()?.as_i64().ok()? as u32;
    let height = dict.get(b"Height").ok()?.as_i64().ok()? as u32;
    let color_space_name = dict.get(b"ColorSpace").ok().and_then(|o| o.as_name().ok());
        
    let color_space = if let Some(name) = color_space_name {
        match name {
            b"DeviceRGB" => PdfColorSpace::DeviceRGB,
            b"DeviceGray" => PdfColorSpace::DeviceGray,
            b"DeviceCMYK" => PdfColorSpace::DeviceCMYK,
            b"Lab" => PdfColorSpace::Lab,
            _ => PdfColorSpace::Other(String::from_utf8_lossy(name).into_owned()),
        }
    } else {
        PdfColorSpace::DeviceRGB
    };

    let bits_per_component = dict.get(b"BitsPerComponent").ok()
        .and_then(|o| o.as_i64().ok())
        .map(|i| i as u8);

    let resolver = |id_gen| {
        if let Ok(obj) = doc.get_object(id_gen) {
             if let Object::Stream(s) = obj {
                 s.decompressed_content().ok()
             } else { None }
        } else { None }
    };

    let data = decode_image_stream(stream, Some(&resolver)).unwrap_or_else(|_| stream.content.clone());

    let (x, y) = ts.pos();
    Some(PdfImage {
        width,
        height,
        data,
        color_space,
        bits_per_component,
        x,
        y,
        clip: None,
        transparency: PdfTransparency::default(),
    })
}

fn create_inline_image(dict: &HashMap<String, Object>, data: &[u8], ts: &TextState, doc: &Document) -> Option<PdfImage> {
    let get_val = |full: &str, abbr: &str| {
        dict.get(full).or_else(|| dict.get(abbr))
    };

    let width = get_val("Width", "W").and_then(|o| o.as_i64().ok())? as u32;
    let height = get_val("Height", "H").and_then(|o| o.as_i64().ok())? as u32;
    
    let color_space_name = get_val("ColorSpace", "CS").and_then(|o| o.as_name().ok());

    let color_space = if let Some(name) = color_space_name {
        match name {
            b"DeviceRGB" => PdfColorSpace::DeviceRGB,
            b"DeviceGray" => PdfColorSpace::DeviceGray,
            b"DeviceCMYK" => PdfColorSpace::DeviceCMYK,
            b"Lab" => PdfColorSpace::Lab,
            _ => PdfColorSpace::Other(String::from_utf8_lossy(name).into_owned()),
        }
    } else {
        PdfColorSpace::DeviceRGB
    };
        
    let bits_per_component = get_val("BitsPerComponent", "BPC")
        .and_then(|o| o.as_i64().ok())
        .map(|i| i as u8);

    let mut temp_dict = lopdf::Dictionary::new();
    let mut normalized_dict = lopdf::Dictionary::new();
    for (k, v) in dict {
        normalized_dict.set(k.as_bytes().to_vec(), v.clone());
    }
    
    if let Some(f) = dict.get("Filter").or_else(|| dict.get("F")) {
        temp_dict.set("Filter", f.clone());
    }
    if let Some(dp) = dict.get("DecodeParms").or_else(|| dict.get("DP")) {
        temp_dict.set("DecodeParms", dp.clone());
    }
    
    if temp_dict.get(b"Filter").is_ok() {
        temp_dict.set("DecodeParms", Object::Dictionary(normalized_dict.clone()));
    }
    
    if !temp_dict.has(b"Filter") {
         if let Some(f) = dict.get("F") {
             temp_dict.set("Filter", f.clone());
         }
    }

    let resolver = |id_gen| {
        if let Ok(obj) = doc.get_object(id_gen) {
             if let Object::Stream(s) = obj {
                 s.decompressed_content().ok()
             } else { None }
        } else { None }
    };

    let decoded_data = decode_image_data(data, &temp_dict, Some(&resolver)).unwrap_or_else(|_| data.to_vec());

    let (x, y) = ts.pos();
    Some(PdfImage {
        width,
        height,
        data: decoded_data,
        color_space,
        bits_per_component,
        x,
        y,
        clip: None,
        transparency: PdfTransparency::default(),
    })
}

fn transform(x: f32, y: f32, ctm: &[f32; 6]) -> (f32, f32) {
    let tx = x * ctm[0] + y * ctm[2] + ctm[4];
    let ty = x * ctm[1] + y * ctm[3] + ctm[5];
    (tx, ty)
}

fn get_metadata_string(dict: &lopdf::Dictionary, key: &[u8]) -> Option<String> {
    dict.get(key).ok().and_then(|o| match o {
        Object::String(bytes, _) => Some(String::from_utf8_lossy(bytes).into_owned()),
        Object::Name(bytes) => Some(String::from_utf8_lossy(bytes).into_owned()),
        _ => None,
    })
}

/// Extract metadata from PDF document
pub fn extract_metadata(doc: &Document) -> PdfMetadata {
    let info_obj = doc.trailer.get(b"Info");
    let info = match info_obj {
        Ok(Object::Reference(ref_id)) => doc.get_object(*ref_id).ok().and_then(|o| o.as_dict().ok()),
        Ok(Object::Dictionary(d)) => Some(d),
        _ => None,
    };
        
    let mut meta = PdfMetadata {
        title: None,
        author: None,
        creator: None,
        producer: None,
    };
    
    if let Some(dict) = info {
        meta.title = get_metadata_string(dict, b"Title");
        meta.author = get_metadata_string(dict, b"Author");
        meta.creator = get_metadata_string(dict, b"Creator");
        meta.producer = get_metadata_string(dict, b"Producer");
    }
    meta
}

/// Build a complete PDF document model
pub fn build_document(doc: &Document) -> PdfDocument {
    let metadata = extract_metadata(doc);
    let mut pages = Vec::new();
    
    let mut page_nums: Vec<_> = doc.get_pages().keys().cloned().collect();
    page_nums.sort();
    
    for page_num in page_nums {
        let page_idx = (page_num - 1) as usize;
        let elements = parse_text_elements(doc, page_idx);
        let text_content = elements.iter().filter_map(|e| match e {
            PdfElement::Text(t) => Some(t.content.clone()),
            _ => None,
        }).collect::<Vec<_>>().join(" ");
        
        let text_lines = wrap_text_elements(&elements.iter().filter_map(|e| match e {
            PdfElement::Text(t) => Some(t.clone()),
            _ => None,
        }).collect::<Vec<_>>());

        pages.push(PdfPage {
            index: page_idx,
            text: text_content,
            elements,
            lines: text_lines,
        });
    }
    
    // Parse document structure
    let annotations = super::annotations::parse_annotations(doc);
    let form_fields = super::forms::parse_acroform(doc);
    
    // Parse bookmarks, attachments, destinations, and structure tree
    let bookmarks = super::outlines::parse_bookmarks(doc);
    let attachments = super::outlines::parse_attachments(doc);
    let named_destinations = super::outlines::parse_named_destinations(doc);
    let structure_tree = super::outlines::parse_structure_tree(doc);
    
    PdfDocument {
        metadata,
        pages,
        form_fields,
        annotations,
        bookmarks,
        attachments,
        named_destinations,
        structure_tree,
    }
}

/// Extract all text from a PDF document
pub fn extract_text(doc: &Document) -> String {
    let mut out = String::new();
    let pages = doc.get_pages();
    for (i, (_page_num, _page_id)) in pages.iter().enumerate() {
        if i > 0 {
            out.push_str("\n\n--- PAGE BREAK ---\n\n");
        }
        let elements = parse_text_elements(doc, i); 
        let text: Vec<String> = elements.iter().filter_map(|e| match e {
            PdfElement::Text(t) => Some(t.content.clone()),
            _ => None,
        }).collect();
        
        out.push_str(&text.join(" "));
    }
    out
}
