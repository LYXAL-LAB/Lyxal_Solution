//! Image filter decoders for PDF
//!
//! Supports all major PDF image filters:
//! - FlateDecode (zlib/deflate)
//! - DCTDecode (JPEG)
//! - CCITTFaxDecode (Group 3/4 fax)
//! - JBIG2Decode (JBIG2 compression)
//! - LZWDecode (LZW compression)
//! - ASCIIHexDecode
//! - ASCII85Decode
//! - RunLengthDecode

use lopdf::{Dictionary, Object, Stream};
use std::io::{Read, Cursor};

/// Image decoding error
#[derive(Debug)]
pub enum ImageFilterError {
    NotImplemented(String),
    DecodeError(String),
    InvalidParameters(String),
}

impl std::fmt::Display for ImageFilterError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::NotImplemented(s) => write!(f, "Not implemented: {}", s),
            Self::DecodeError(s) => write!(f, "Decode error: {}", s),
            Self::InvalidParameters(s) => write!(f, "Invalid parameters: {}", s),
        }
    }
}

impl std::error::Error for ImageFilterError {}

/// Decoded image with metadata
#[derive(Debug, Clone)]
pub struct DecodedImage {
    pub data: Vec<u8>,
    pub width: u32,
    pub height: u32,
    pub color_type: ImageColorType,
    pub bits_per_component: u8,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum ImageColorType {
    Gray,
    GrayAlpha,
    Rgb,
    Rgba,
    Indexed,
    Cmyk,
}

/// Decode an image stream applying the filter chain
pub fn decode_image_stream<F>(stream: &Stream, resolver: Option<&F>) -> Result<Vec<u8>, ImageFilterError> 
where F: Fn((u32, u16)) -> Option<Vec<u8>>
{
    decode_image_data(&stream.content, &stream.dict, resolver)
}

/// Decode raw image data using the dictionary for Filter/DecodeParms
pub fn decode_image_data<F>(data: &[u8], dict: &Dictionary, resolver: Option<&F>) -> Result<Vec<u8>, ImageFilterError> 
where F: Fn((u32, u16)) -> Option<Vec<u8>>
{
    let filters = get_filters(dict);
    let decode_parms = get_decode_parms(dict);
    
    // If no filters, return raw data
    if filters.is_empty() {
        return Ok(data.to_vec());
    }
    
    let mut current_data = data.to_vec();
    
    for (i, filter_name) in filters.iter().enumerate() {
        let params = decode_parms.get(i).cloned().flatten();
        
        current_data = match filter_name.as_str() {
            "FlateDecode" | "Fl" => {
                decode_flate(&current_data, params.as_ref())
                    .map_err(|e| ImageFilterError::DecodeError(e.to_string()))?
            }
            "DCTDecode" | "DCT" => {
                decode_dct(&current_data)
                    .map_err(|e| ImageFilterError::DecodeError(e.to_string()))?
            }
            "CCITTFaxDecode" | "CCF" => {
                decode_ccitt(&current_data, params)
                    .map_err(|e| ImageFilterError::DecodeError(e))?
            }
            "JBIG2Decode" => {
                let globals = if let Some(p) = &params {
                    if let Ok(obj) = p.get(b"JBIG2Globals") {
                        if let Ok((id, gen)) = obj.as_reference() {
                            resolver.and_then(|r| r((id, gen)))
                        } else { None }
                    } else { None }
                } else {
                    None
                };
                decode_jbig2(&current_data, globals)
                    .map_err(|e| ImageFilterError::DecodeError(e))?
            }
            "LZWDecode" | "LZW" => {
                decode_lzw(&current_data, params.as_ref())
                    .map_err(|e| ImageFilterError::DecodeError(e.to_string()))?
            }
            "ASCIIHexDecode" | "AHx" => {
                decode_ascii_hex(&current_data)
                    .map_err(|e| ImageFilterError::DecodeError(e))?
            }
            "ASCII85Decode" | "A85" => {
                decode_ascii85(&current_data)
                    .map_err(|e| ImageFilterError::DecodeError(e))?
            }
            "RunLengthDecode" | "RL" => {
                decode_run_length(&current_data)
                    .map_err(|e| ImageFilterError::DecodeError(e))?
            }
            "JPXDecode" => {
                // JPEG2000 - not commonly used, mark as passthrough
                // The data can still be used by external JPEG2000 decoders
                return Err(ImageFilterError::NotImplemented(
                    "JPXDecode (JPEG2000) - data available as raw bytes".to_string()
                ));
            }
            "Crypt" => {
                // Crypt filter is handled at document level
                current_data
            }
            _ => {
                return Err(ImageFilterError::NotImplemented(format!("Filter: {}", filter_name)));
            }
        };
    }
    
    Ok(current_data)
}

/// Decode image stream and return full image info
pub fn decode_image_full<F>(stream: &Stream, resolver: Option<&F>) -> Result<DecodedImage, ImageFilterError>
where F: Fn((u32, u16)) -> Option<Vec<u8>>
{
    let dict = &stream.dict;
    
    // Get image dimensions
    let width = dict.get(b"Width")
        .ok().and_then(|o| o.as_i64().ok())
        .unwrap_or(0) as u32;
    let height = dict.get(b"Height")
        .ok().and_then(|o| o.as_i64().ok())
        .unwrap_or(0) as u32;
    let bits = dict.get(b"BitsPerComponent")
        .ok().and_then(|o| o.as_i64().ok())
        .unwrap_or(8) as u8;
    
    // Determine color type from ColorSpace
    let color_type = get_color_type(dict);
    
    // Check if it's a pure DCT/JPEG - in that case, decode directly to RGB
    let filters = get_filters(dict);
    if filters.len() == 1 && (filters[0] == "DCTDecode" || filters[0] == "DCT") {
        return decode_jpeg_full(&stream.content, width, height);
    }
    
    // Standard decode
    let data = decode_image_stream(stream, resolver)?;
    
    Ok(DecodedImage {
        data,
        width,
        height,
        color_type,
        bits_per_component: bits,
    })
}

fn get_color_type(dict: &Dictionary) -> ImageColorType {
    match dict.get(b"ColorSpace") {
        Ok(Object::Name(name)) => {
            match name.as_slice() {
                b"DeviceGray" | b"G" => ImageColorType::Gray,
                b"DeviceRGB" | b"RGB" => ImageColorType::Rgb,
                b"DeviceCMYK" | b"CMYK" => ImageColorType::Cmyk,
                b"Indexed" | b"I" => ImageColorType::Indexed,
                _ => ImageColorType::Rgb,
            }
        }
        Ok(Object::Array(arr)) => {
            if let Some(Object::Name(name)) = arr.first() {
                match name.as_slice() {
                    b"Indexed" | b"I" => ImageColorType::Indexed,
                    b"ICCBased" => {
                        // Check N value for ICC profile
                        if let Some(Object::Reference(_)) = arr.get(1) {
                            // Would need to resolve reference to check /N
                            ImageColorType::Rgb
                        } else {
                            ImageColorType::Rgb
                        }
                    }
                    b"DeviceGray" | b"CalGray" => ImageColorType::Gray,
                    b"DeviceRGB" | b"CalRGB" => ImageColorType::Rgb,
                    b"DeviceCMYK" => ImageColorType::Cmyk,
                    _ => ImageColorType::Rgb,
                }
            } else {
                ImageColorType::Rgb
            }
        }
        _ => ImageColorType::Rgb,
    }
}

fn get_filters(dict: &Dictionary) -> Vec<String> {
    match dict.get(b"Filter") {
        Ok(Object::Name(n)) => vec![String::from_utf8_lossy(n).to_string()],
        Ok(Object::Array(arr)) => arr.iter()
            .filter_map(|o| o.as_name().ok().map(|n| String::from_utf8_lossy(n).to_string()))
            .collect(),
        _ => vec![],
    }
}

fn get_decode_parms(dict: &Dictionary) -> Vec<Option<Dictionary>> {
    match dict.get(b"DecodeParms") {
        Ok(Object::Dictionary(d)) => vec![Some(d.clone())],
        Ok(Object::Array(arr)) => arr.iter().map(|o| o.as_dict().ok().cloned()).collect(),
        Ok(Object::Null) => vec![None],
        _ => vec![None], 
    }
}

// ============================================================================
// FILTER IMPLEMENTATIONS
// ============================================================================

/// FlateDecode (zlib/deflate compression)
fn decode_flate(data: &[u8], params: Option<&Dictionary>) -> Result<Vec<u8>, std::io::Error> {
    use flate2::read::ZlibDecoder;
    
    let mut decoder = ZlibDecoder::new(data);
    let mut decompressed = Vec::new();
    decoder.read_to_end(&mut decompressed)?;
    
    // Apply predictor if specified
    if let Some(p) = params {
        let predictor = p.get(b"Predictor").ok().and_then(|o| o.as_i64().ok()).unwrap_or(1);
        if predictor > 1 {
            let columns = p.get(b"Columns").ok().and_then(|o| o.as_i64().ok()).unwrap_or(1) as usize;
            let colors = p.get(b"Colors").ok().and_then(|o| o.as_i64().ok()).unwrap_or(1) as usize;
            let bits = p.get(b"BitsPerComponent").ok().and_then(|o| o.as_i64().ok()).unwrap_or(8) as usize;
            
            decompressed = apply_predictor(predictor as i32, &decompressed, columns, colors, bits)?;
        }
    }
    
    Ok(decompressed)
}

/// DCTDecode (JPEG) - decode to raw RGB pixels
fn decode_dct(data: &[u8]) -> Result<Vec<u8>, String> {
    use image::io::Reader as ImageReader;
    
    let cursor = Cursor::new(data);
    let reader = ImageReader::with_format(cursor, image::ImageFormat::Jpeg);
    
    let img = reader.decode()
        .map_err(|e| format!("JPEG decode error: {}", e))?;
    
    // Convert to RGB8
    let rgb = img.to_rgb8();
    Ok(rgb.into_raw())
}

/// Decode JPEG with full metadata
fn decode_jpeg_full(data: &[u8], _width: u32, _height: u32) -> Result<DecodedImage, ImageFilterError> {
    use image::io::Reader as ImageReader;
    
    let cursor = Cursor::new(data);
    let reader = ImageReader::with_format(cursor, image::ImageFormat::Jpeg);
    
    let img = reader.decode()
        .map_err(|e| ImageFilterError::DecodeError(format!("JPEG decode error: {}", e)))?;
    
    let (width, height) = (img.width(), img.height());
    let rgb = img.to_rgb8();
    
    Ok(DecodedImage {
        data: rgb.into_raw(),
        width,
        height,
        color_type: ImageColorType::Rgb,
        bits_per_component: 8,
    })
}

/// LZWDecode
fn decode_lzw(data: &[u8], params: Option<&Dictionary>) -> Result<Vec<u8>, std::io::Error> {
    use weezl::{decode::Decoder, BitOrder};
    
    // PDF uses MSB first, early code = 9 bits (min code size 8)
    let mut decoder = Decoder::new(BitOrder::Msb, 8);
    let mut decompressed = Vec::new();
    
    // Use into_vec adapter for in-memory decoding
    let result = decoder.into_vec(&mut decompressed).decode_all(data);
    
    if let Err(e) = result.status {
        return Err(std::io::Error::new(std::io::ErrorKind::InvalidData, format!("LZW error: {:?}", e)));
    }
    
    // Truncate to actual decoded length
    decompressed.truncate(result.consumed_out);
    
    // Apply predictor if specified
    if let Some(p) = params {
        let predictor = p.get(b"Predictor").ok().and_then(|o| o.as_i64().ok()).unwrap_or(1);
        if predictor > 1 {
            let columns = p.get(b"Columns").ok().and_then(|o| o.as_i64().ok()).unwrap_or(1) as usize;
            let colors = p.get(b"Colors").ok().and_then(|o| o.as_i64().ok()).unwrap_or(1) as usize;
            let bits = p.get(b"BitsPerComponent").ok().and_then(|o| o.as_i64().ok()).unwrap_or(8) as usize;
            
            decompressed = apply_predictor(predictor as i32, &decompressed, columns, colors, bits)?;
        }
    }
    
    Ok(decompressed)
}

/// CCITTFaxDecode (Group 3/4 fax)
fn decode_ccitt(data: &[u8], params: Option<Dictionary>) -> Result<Vec<u8>, String> {
    use crate::vendors::fax::decoder::{decode_g3, decode_g4};
    
    let mut k = 0;
    let mut columns = 1728;
    let mut rows = 0;
    let mut black_is_1 = false;

    if let Some(p) = params {
        if let Ok(v) = p.get(b"K").and_then(|o| o.as_i64()) { k = v as i32; }
        if let Ok(v) = p.get(b"Columns").and_then(|o| o.as_i64()) { columns = v as u32; }
        if let Ok(v) = p.get(b"Rows").and_then(|o| o.as_i64()) { rows = v as u32; }
        if let Ok(v) = p.get(b"BlackIs1").and_then(|o| o.as_bool()) { black_is_1 = v; }
    }

    let mut output = Vec::new();
    let row_bytes = ((columns + 7) / 8) as usize;

    let line_cb = |runs: &[u16]| {
        let mut line_buf = vec![0u8; row_bytes];
        let mut bit_idx = 0u32;
        let mut is_white = true;
        
        for &len in runs {
            let bit_val = if is_white { 
                if black_is_1 { 0 } else { 1 }
            } else {
                if black_is_1 { 1 } else { 0 }
            };
            
            for _ in 0..len {
                if bit_idx >= columns { break; } 
                if bit_val == 1 {
                    line_buf[(bit_idx / 8) as usize] |= 1 << (7 - (bit_idx % 8));
                }
                bit_idx += 1;
            }
            is_white = !is_white;
        }
        output.extend_from_slice(&line_buf);
    };

    if k < 0 {
        // Group 4
        let height_opt = if rows > 0 { Some(rows as u16) } else { None };
        if decode_g4(data.iter().cloned(), columns as u16, height_opt, line_cb).is_some() {
            Ok(output)
        } else {
            Err(format!("CCITT G4 decoding failed (K={})", k))
        }
    } else {
        // Group 3
        if decode_g3(data.iter().cloned(), line_cb).is_some() {
            Ok(output)
        } else {
            Err(format!("CCITT G3 decoding failed (K={})", k))
        }
    }
}

/// JBIG2Decode
fn decode_jbig2(data: &[u8], globals_ref: Option<Vec<u8>>) -> Result<Vec<u8>, String> {
    use jbig2dec::Document;
    
    let full_data = if let Some(globals) = globals_ref {
        let mut v = globals;
        v.extend_from_slice(data);
        v
    } else {
        data.to_vec()
    };

    let mut cursor = Cursor::new(&full_data);
    let doc = Document::from_reader(&mut cursor)
        .map_err(|e| format!("JBIG2 decoding failed: {:?}", e))?;

    let mut output = Vec::new();
    for image in doc {
        output.extend_from_slice(image.data());
    }

    if output.is_empty() {
        return Err("JBIG2 decoding produced empty result".to_string());
    }

    Ok(output)
}

/// ASCIIHexDecode
fn decode_ascii_hex(data: &[u8]) -> Result<Vec<u8>, String> {
    let mut result = Vec::with_capacity(data.len() / 2);
    let mut high_nibble: Option<u8> = None;
    
    for &byte in data {
        // Skip whitespace
        if byte.is_ascii_whitespace() {
            continue;
        }
        // End of data marker
        if byte == b'>' {
            break;
        }
        
        let nibble = match byte {
            b'0'..=b'9' => byte - b'0',
            b'A'..=b'F' => byte - b'A' + 10,
            b'a'..=b'f' => byte - b'a' + 10,
            _ => return Err(format!("Invalid hex character: {}", byte as char)),
        };
        
        match high_nibble {
            None => high_nibble = Some(nibble),
            Some(high) => {
                result.push((high << 4) | nibble);
                high_nibble = None;
            }
        }
    }
    
    // If odd number of hex digits, append 0
    if let Some(high) = high_nibble {
        result.push(high << 4);
    }
    
    Ok(result)
}

/// ASCII85Decode (Base85)
fn decode_ascii85(data: &[u8]) -> Result<Vec<u8>, String> {
    let mut result = Vec::new();
    let mut tuple: u32 = 0;
    let mut count = 0;
    
    // Skip leading <~ if present
    let start = if data.starts_with(b"<~") { 2 } else { 0 };
    
    for &byte in &data[start..] {
        // Skip whitespace
        if byte.is_ascii_whitespace() {
            continue;
        }
        // End of data
        if byte == b'~' || byte == b'>' {
            break;
        }
        // Special 'z' = four zero bytes
        if byte == b'z' {
            if count != 0 {
                return Err("'z' inside ASCII85 group".to_string());
            }
            result.extend_from_slice(&[0, 0, 0, 0]);
            continue;
        }
        
        if byte < b'!' || byte > b'u' {
            return Err(format!("Invalid ASCII85 character: {}", byte as char));
        }
        
        tuple = tuple * 85 + (byte - b'!') as u32;
        count += 1;
        
        if count == 5 {
            result.push((tuple >> 24) as u8);
            result.push((tuple >> 16) as u8);
            result.push((tuple >> 8) as u8);
            result.push(tuple as u8);
            tuple = 0;
            count = 0;
        }
    }
    
    // Handle remaining bytes
    if count > 0 {
        for _ in count..5 {
            tuple = tuple * 85 + 84; // Pad with 'u'
        }
        for i in 0..(count - 1) {
            result.push((tuple >> (24 - i * 8)) as u8);
        }
    }
    
    Ok(result)
}

/// RunLengthDecode
fn decode_run_length(data: &[u8]) -> Result<Vec<u8>, String> {
    let mut result = Vec::new();
    let mut i = 0;
    
    while i < data.len() {
        let length = data[i];
        
        if length == 128 {
            // EOD marker
            break;
        } else if length < 128 {
            // Copy next (length + 1) bytes literally
            let count = (length as usize) + 1;
            if i + 1 + count > data.len() {
                return Err("RunLength: unexpected end of data".to_string());
            }
            result.extend_from_slice(&data[i + 1..i + 1 + count]);
            i += 1 + count;
        } else {
            // Repeat next byte (257 - length) times
            let count = 257 - (length as usize);
            if i + 1 >= data.len() {
                return Err("RunLength: unexpected end of data".to_string());
            }
            let byte = data[i + 1];
            for _ in 0..count {
                result.push(byte);
            }
            i += 2;
        }
    }
    
    Ok(result)
}

// ============================================================================
// PREDICTOR SUPPORT
// ============================================================================

/// Apply PNG/TIFF predictor to decompressed data
fn apply_predictor(predictor: i32, data: &[u8], columns: usize, colors: usize, bits: usize) -> Result<Vec<u8>, std::io::Error> {
    if predictor == 1 {
        return Ok(data.to_vec());
    }
    
    let bytes_per_pixel = (colors * bits + 7) / 8;
    let row_bytes = (columns * colors * bits + 7) / 8;
    
    match predictor {
        2 => {
            // TIFF predictor 2 (horizontal differencing)
            apply_tiff_predictor(data, row_bytes, bytes_per_pixel)
        }
        10..=15 => {
            // PNG predictors
            apply_png_predictor(data, row_bytes, bytes_per_pixel)
        }
        _ => Ok(data.to_vec()),
    }
}

fn apply_tiff_predictor(data: &[u8], row_bytes: usize, bytes_per_pixel: usize) -> Result<Vec<u8>, std::io::Error> {
    let mut result = Vec::with_capacity(data.len());
    
    for row in data.chunks(row_bytes) {
        let mut prev = vec![0u8; bytes_per_pixel];
        for pixel in row.chunks(bytes_per_pixel) {
            let mut decoded = Vec::with_capacity(bytes_per_pixel);
            for (i, &b) in pixel.iter().enumerate() {
                let val = b.wrapping_add(prev.get(i).copied().unwrap_or(0));
                decoded.push(val);
            }
            result.extend_from_slice(&decoded);
            prev = decoded;
        }
    }
    
    Ok(result)
}

fn apply_png_predictor(data: &[u8], row_bytes: usize, bytes_per_pixel: usize) -> Result<Vec<u8>, std::io::Error> {
    let mut result = Vec::new();
    let mut prev_row = vec![0u8; row_bytes];
    
    // Each row has a filter byte prefix
    let actual_row_bytes = row_bytes + 1;
    
    for row in data.chunks(actual_row_bytes) {
        if row.is_empty() {
            continue;
        }
        
        let filter = row[0];
        let row_data = &row[1..];
        
        let mut decoded_row = Vec::with_capacity(row_bytes);
        
        for (i, &byte) in row_data.iter().enumerate() {
            let a = if i >= bytes_per_pixel { decoded_row[i - bytes_per_pixel] } else { 0 };
            let b = prev_row.get(i).copied().unwrap_or(0);
            let c = if i >= bytes_per_pixel { prev_row.get(i - bytes_per_pixel).copied().unwrap_or(0) } else { 0 };
            
            let decoded = match filter {
                0 => byte, // None
                1 => byte.wrapping_add(a), // Sub
                2 => byte.wrapping_add(b), // Up
                3 => byte.wrapping_add(((a as u16 + b as u16) / 2) as u8), // Average
                4 => byte.wrapping_add(paeth_predictor(a, b, c)), // Paeth
                _ => byte,
            };
            
            decoded_row.push(decoded);
        }
        
        result.extend_from_slice(&decoded_row);
        prev_row = decoded_row;
    }
    
    Ok(result)
}

fn paeth_predictor(a: u8, b: u8, c: u8) -> u8 {
    let a = a as i32;
    let b = b as i32;
    let c = c as i32;
    
    let p = a + b - c;
    let pa = (p - a).abs();
    let pb = (p - b).abs();
    let pc = (p - c).abs();
    
    if pa <= pb && pa <= pc {
        a as u8
    } else if pb <= pc {
        b as u8
    } else {
        c as u8
    }
}

// ============================================================================
// COLOR SPACE CONVERSION
// ============================================================================

/// Convert CMYK to RGB
pub fn cmyk_to_rgb(cmyk: &[u8]) -> Vec<u8> {
    let mut rgb = Vec::with_capacity(cmyk.len() * 3 / 4);
    
    for chunk in cmyk.chunks(4) {
        if chunk.len() < 4 {
            break;
        }
        
        let c = chunk[0] as f32 / 255.0;
        let m = chunk[1] as f32 / 255.0;
        let y = chunk[2] as f32 / 255.0;
        let k = chunk[3] as f32 / 255.0;
        
        let r = 255.0 * (1.0 - c) * (1.0 - k);
        let g = 255.0 * (1.0 - m) * (1.0 - k);
        let b = 255.0 * (1.0 - y) * (1.0 - k);
        
        rgb.push(r.clamp(0.0, 255.0) as u8);
        rgb.push(g.clamp(0.0, 255.0) as u8);
        rgb.push(b.clamp(0.0, 255.0) as u8);
    }
    
    rgb
}

/// Convert grayscale to RGB
pub fn gray_to_rgb(gray: &[u8]) -> Vec<u8> {
    let mut rgb = Vec::with_capacity(gray.len() * 3);
    
    for &g in gray {
        rgb.push(g);
        rgb.push(g);
        rgb.push(g);
    }
    
    rgb
}
