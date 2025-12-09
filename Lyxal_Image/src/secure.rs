use crate::core::LyxalImage;
use crate::error::LyxalResult;
use img_hash::{HasherConfig, HashAlg};

impl LyxalImage {
    pub fn phash(&self) -> LyxalResult<String> {
        self.with_inner(|img| {
            let hasher = HasherConfig::new().hash_alg(HashAlg::DoubleGradient).to_hasher();
            let hash = hasher.hash_image(&*img);
            Ok(hash.to_base64())
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
}