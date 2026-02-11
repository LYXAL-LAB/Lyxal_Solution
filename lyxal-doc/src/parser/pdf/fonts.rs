//! Font handling for PDF reading

use lopdf::{Document, Object};
use std::collections::HashMap;
use ttf_parser::Face;
use crate::parser::pdf::common::PdfBBox;

#[derive(Debug, Clone)]
pub struct FontData {
    pub units_per_em: f32,
    pub advances: HashMap<u16, f32>, // GID/CID -> Advance
    pub glyph_bboxes: HashMap<u16, PdfBBox>, // GID/CID -> BBox
    pub to_unicode: HashMap<u32, String>, // CharCode (CID/Byte) -> Unicode String
    pub default_width: f32,
    pub is_cid: bool,
}

impl Default for FontData {
    fn default() -> Self {
        Self {
            units_per_em: 1000.0,
            advances: HashMap::new(),
            glyph_bboxes: HashMap::new(),
            to_unicode: HashMap::new(),
            default_width: 0.0,
            is_cid: false,
        }
    }
}

pub fn load_font(doc: &Document, font_dict: &lopdf::Dictionary) -> Option<FontData> {
    let mut font_data = FontData::default();
    let mut metrics_found = false;
    
    let subtype = font_dict.get(b"Subtype").and_then(|o| o.as_name()).unwrap_or(b"Type1");
    
    if let Ok(to_unicode_ref) = font_dict.get(b"ToUnicode") {
        if let Ok(stream_obj) = doc.get_object(to_unicode_ref.as_reference().unwrap_or((0,0))) {
             if let Ok(stream) = stream_obj.as_stream() {
                let content = stream.decompressed_content().unwrap_or_else(|_| stream.content.clone());
                parse_to_unicode(&content, &mut font_data.to_unicode);
             }
        }
    }

    match subtype {
        b"Type0" => {
            font_data.is_cid = true;
            if let Ok(descendants) = font_dict.get(b"DescendantFonts").and_then(|o| o.as_array()) {
                if let Some(cid_font_obj) = descendants.get(0) {
                    let cid_font_dict = match cid_font_obj {
                        Object::Reference(r) => doc.get_dictionary(*r).ok(),
                        Object::Dictionary(d) => Some(d),
                        _ => None,
                    };
                    
                    if let Some(cid_dict) = cid_font_dict {
                        load_cid_widths(cid_dict, &mut font_data);
                        metrics_found = true;
                        
                        if let Ok(fd_ref) = cid_dict.get(b"FontDescriptor") {
                             let fd_dict = match fd_ref {
                                 Object::Reference(r) => doc.get_dictionary(*r).ok(),
                                 Object::Dictionary(d) => Some(d),
                                 _ => None,
                             };
                             if let Some(fd) = fd_dict {
                                 load_font_file(doc, fd, &mut font_data);
                             }
                        }
                    }
                }
            }
        },
        b"TrueType" | b"Type1" | b"MMType1" => {
            font_data.is_cid = false;
            if let (Ok(first), Ok(widths)) = (font_dict.get(b"FirstChar").and_then(|o| o.as_i64()), font_dict.get(b"Widths").and_then(|o| o.as_array())) {
                let first = first as u16;
                for (i, w) in widths.iter().enumerate() {
                    if let Some(val) = as_f32_helper(w) {
                        font_data.advances.insert(first + i as u16, val);
                    }
                }
                metrics_found = true;
            }
            
            if let Ok(fd_ref) = font_dict.get(b"FontDescriptor") {
                 let fd_dict = match fd_ref {
                     Object::Reference(r) => doc.get_dictionary(*r).ok(),
                     Object::Dictionary(d) => Some(d),
                     _ => None,
                 };
                 if let Some(fd) = fd_dict {
                     load_font_file(doc, fd, &mut font_data);
                     if !font_data.advances.is_empty() {
                         metrics_found = true;
                     }
                 }
            }
        },
        _ => {}
    }

    if metrics_found || !font_data.advances.is_empty() || !font_data.to_unicode.is_empty() {
        Some(font_data)
    } else {
        None
    }
}

fn load_cid_widths(dict: &lopdf::Dictionary, font_data: &mut FontData) {
    if let Some(dw) = dict.get(b"DW").ok().and_then(as_f32_helper) {
        font_data.default_width = dw;
    } else {
        font_data.default_width = 1000.0;
    }

    if let Ok(w_arr) = dict.get(b"W").and_then(|o| o.as_array()) {
        let mut i = 0;
        while i < w_arr.len() {
            if let Ok(c) = w_arr[i].as_i64() {
                let start_cid = c as u16;
                i += 1;
                if i >= w_arr.len() { break; }
                
                match &w_arr[i] {
                    Object::Array(widths) => {
                        for (offset, w_obj) in widths.iter().enumerate() {
                            if let Some(w) = as_f32_helper(w_obj) {
                                font_data.advances.insert(start_cid + offset as u16, w);
                            }
                        }
                        i += 1;
                    },
                    Object::Integer(end_cid) => {
                        let end_cid = *end_cid as u16;
                        i += 1;
                        if i >= w_arr.len() { break; }
                        if let Some(w) = as_f32_helper(&w_arr[i]) {
                            for cid in start_cid..=end_cid {
                                font_data.advances.insert(cid, w);
                            }
                        }
                        i += 1;
                    },
                    Object::Real(_) => {
                         i += 1;
                    }
                    _ => i += 1,
                }
            } else {
                i += 1;
            }
        }
    }
}

fn as_f32_helper(obj: &Object) -> Option<f32> {
    match obj {
        Object::Integer(i) => Some(*i as f32),
        Object::Real(f) => Some(*f as f32),
        _ => None,
    }
}

fn load_font_file(doc: &Document, fd: &lopdf::Dictionary, font_data: &mut FontData) {
    let font_file_key = if fd.has(b"FontFile3") {
        b"FontFile3".as_slice()
    } else if fd.has(b"FontFile2") {
        b"FontFile2".as_slice()
    } else {
        b"FontFile".as_slice()
    };

    if let Ok(ff_ref) = fd.get(font_file_key) {
        let stream_obj = match ff_ref {
            Object::Reference(r) => doc.get_object(*r).ok(),
            Object::Stream(_) => Some(ff_ref),
            _ => None,
        };

        if let Some(Object::Stream(s)) = stream_obj {
            if let Ok(data) = s.decompressed_content() {
                if let Ok(face) = Face::parse(&data, 0) {
                    font_data.units_per_em = face.units_per_em() as f32;
                    let scale = 1000.0 / font_data.units_per_em;

                    let count = face.number_of_glyphs();
                    for gid in 0..count {
                        let id = ttf_parser::GlyphId(gid);
                        
                        if !font_data.advances.contains_key(&gid) {
                            if let Some(adv) = face.glyph_hor_advance(id) {
                                font_data.advances.insert(gid, adv as f32 * scale);
                            }
                        }
                        
                        if let Some(bbox) = face.glyph_bounding_box(id) {
                            font_data.glyph_bboxes.insert(gid, PdfBBox {
                                min_x: bbox.x_min as f32 * scale,
                                min_y: bbox.y_min as f32 * scale,
                                max_x: bbox.x_max as f32 * scale,
                                max_y: bbox.y_max as f32 * scale,
                            });
                        }
                    }
                }
            }
        }
    }
}

fn parse_to_unicode(content: &[u8], map: &mut HashMap<u32, String>) {
    let s = String::from_utf8_lossy(content);
    let mut tokens = s.split_whitespace();
    while let Some(token) = tokens.next() {
        if token == "beginbfchar" {
            parse_bfchar(&mut tokens, map);
        } else if token == "beginbfrange" {
            parse_bfrange(&mut tokens, map);
        }
    }
}

fn parse_bfchar<'a, I>(tokens: &mut I, map: &mut HashMap<u32, String>) 
where I: Iterator<Item = &'a str> {
    loop {
        let code_str = match tokens.next() {
            Some("endbfchar") | None => break,
            Some(s) => s,
        };
        let uni_str = match tokens.next() {
            Some(s) => s,
            None => break,
        };
        
        if let (Some(code), Some(uni)) = (parse_hex_string(code_str), parse_hex_string_to_utf8(uni_str)) {
            map.insert(code, uni);
        }
    }
}

fn parse_bfrange<'a, I>(tokens: &mut I, map: &mut HashMap<u32, String>) 
where I: Iterator<Item = &'a str> {
    loop {
        let start_str = match tokens.next() {
            Some("endbfrange") | None => break,
            Some(s) => s,
        };
        let end_str = match tokens.next() {
            Some(s) => s,
            None => break,
        };
        let next_token = match tokens.next() {
            Some(s) => s,
            None => break,
        };
        
        if next_token == "[" {
            if let (Some(start), Some(end)) = (parse_hex_string(start_str), parse_hex_string(end_str)) {
                let mut current = start;
                loop {
                    let val_str = match tokens.next() {
                        Some("]") => break,
                        Some(s) => s,
                        None => break,
                    };
                    if let Some(uni) = parse_hex_string_to_utf8(val_str) {
                        map.insert(current, uni);
                    }
                    if current < end {
                        current += 1;
                    }
                }
            }
        } else {
            if let (Some(start), Some(end), Some(uni_start_vec)) = (parse_hex_string(start_str), parse_hex_string(end_str), parse_hex_bytes(next_token)) {
                let count = end - start + 1;
                if uni_start_vec.len() == 2 {
                    let mut uni_val = u16::from_be_bytes([uni_start_vec[0], uni_start_vec[1]]) as u32;
                    for i in 0..count {
                        if let Some(c) = std::char::from_u32(uni_val + i) {
                            map.insert(start + i, c.to_string());
                        }
                    }
                }
            }
        }
    }
}

fn parse_hex_string(s: &str) -> Option<u32> {
    let inner = s.trim_matches(|c| c == '<' || c == '>');
    u32::from_str_radix(inner, 16).ok()
}

fn parse_hex_bytes(s: &str) -> Option<Vec<u8>> {
    let inner = s.trim_matches(|c| c == '<' || c == '>');
    if inner.len() % 2 != 0 { return None; }
    (0..inner.len())
        .step_by(2)
        .map(|i| u8::from_str_radix(&inner[i..i+2], 16))
        .collect::<Result<Vec<_>, _>>().ok()
}

fn parse_hex_string_to_utf8(s: &str) -> Option<String> {
    let bytes = parse_hex_bytes(s)?;
    if bytes.len() >= 2 {
        let u16s: Vec<u16> = bytes.chunks_exact(2).map(|c| u16::from_be_bytes([c[0], c[1]])).collect();
        String::from_utf16(&u16s).ok()
    } else {
        None
    }
}
