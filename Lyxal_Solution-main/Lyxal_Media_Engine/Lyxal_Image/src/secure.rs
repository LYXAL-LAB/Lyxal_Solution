use crate::core::LyxalImage;
use crate::error::LyxalResult;
use img_hash::{HasherConfig, HashAlg};

impl LyxalImage {
    pub fn phash(&self) -> LyxalResult<String> {
        self.with_inner(|img| {
            let width = img.width();
            let height = img.height();
            let raw = img.to_rgba8().into_raw();
            
            // Bridge pour img_hash (attend image 0.23)
            // On reconstruit une image 0.23 depuis le buffer raw
            if let Some(img_compat) = image_legacy::ImageBuffer::<image_legacy::Rgba<u8>, Vec<u8>>::from_raw(width, height, raw) {
                 let hasher = HasherConfig::new().hash_alg(HashAlg::DoubleGradient).to_hasher();
                 let hash = hasher.hash_image(&img_compat);
                 Ok(hash.to_base64())
            } else {
                 Err(crate::error::LyxalError::InternalError("Failed to convert image for hashing".into()))
            }
        })
    }

    /// Steganography LSB (Invisible Watermark)
    pub fn embed_secret(&mut self, secret: &str) -> LyxalResult<()> {
        self.with_inner(|img| {
            let rgba = img.as_mut_rgba8().ok_or(crate::error::LyxalError::InvalidParam("Image must be RGBA".into()))?;
            
            let mut bits: Vec<u8> = vec![];
            for byte in secret.bytes() {
                for i in 0..8 { bits.push((byte >> i) & 1); }
            }
            for _ in 0..8 { bits.push(0); } // Null terminator

            let mut bit_idx = 0;
            'pixels: for pixel in rgba.pixels_mut() {
                for channel in 0..3 { 
                    if bit_idx >= bits.len() { break 'pixels; }
                    pixel[channel] = (pixel[channel] & 0xFE) | bits[bit_idx];
                    bit_idx += 1;
                }
            }
            Ok(())
        })
    }
    pub fn extract_secret(&self) -> LyxalResult<String> {
        self.with_inner(|img| {
            let rgba = img.to_rgba8();
            let mut bytes: Vec<u8> = Vec::new();
            let mut current_byte = 0u8;
            let mut bit_count = 0;

            for pixel in rgba.pixels() {
                for channel in 0..3 {
                    let bit = pixel[channel] & 1;
                    current_byte |= bit << bit_count;
                    bit_count += 1;

                    if bit_count == 8 {
                        if current_byte == 0 {
                             return String::from_utf8(bytes).map_err(|e| crate::error::LyxalError::InvalidParam(format!("Invalid UTF-8 secret: {}", e)));
                        }
                        bytes.push(current_byte);
                        if bytes.len() > 1024 {
                             return Err(crate::error::LyxalError::InvalidParam("Secret too long or no terminator".into()));
                        }
                        current_byte = 0;
                        bit_count = 0;
                    }
                }
            }
            Err(crate::error::LyxalError::InvalidParam("No secret found (missing null terminator)".into()))
        })
    }
}