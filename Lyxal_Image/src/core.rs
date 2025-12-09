use std::sync::{Arc, Mutex};
use image::DynamicImage;
use crate::error::{LyxalError, LyxalResult};
use crate::context::ImageContext;

#[derive(Clone)]
pub struct LyxalImage {
    // Arc<Mutex> permet de partager l'image entre threads si besoin
    pub(crate) inner: Arc<Mutex<DynamicImage>>,
    pub format: image::ImageFormat,
}

impl LyxalImage {
    pub fn from_bytes(bytes: &[u8], ctx: &ImageContext) -> LyxalResult<Self> {
        // 1. Check taille buffer (Hard limit)
        if bytes.len() > 100 * 1024 * 1024 { // 100 MB
             return Err(LyxalError::QuotaExceeded("Buffer input > 100MB".into()));
        }

        // 2. Decoder
        let reader = image::io::Reader::new(std::io::Cursor::new(bytes))
            .with_guessed_format()
            .map_err(LyxalError::Decode)?;
        
        let format = reader.format().unwrap_or(image::ImageFormat::Png);
        let img = reader.decode().map_err(LyxalError::Decode)?;

        // 3. Check Dimensions
        if img.width() > ctx.max_width || img.height() > ctx.max_height {
            return Err(LyxalError::QuotaExceeded(format!(
                "Dimensions {}x{} > Max {}x{}", 
                img.width(), img.height(), ctx.max_width, ctx.max_height
            )));
        }
        
        if (img.width() as u64 * img.height() as u64) > ctx.max_pixels {
             return Err(LyxalError::QuotaExceeded("Pixel limit exceeded".into()));
        }

        Ok(Self {
            inner: Arc::new(Mutex::new(img)),
            format,
        })
    }

    pub fn to_bytes(&self, format: image::ImageFormat) -> LyxalResult<Vec<u8>> {
        let img = self.inner.lock().map_err(|_| LyxalError::LockError)?;
        let mut bytes: Vec<u8> = Vec::new();
        let mut cursor = std::io::Cursor::new(&mut bytes);
        
        img.write_to(&mut cursor, format)
            .map_err(LyxalError::Decode)?;
            
        Ok(bytes)
    }

    // Helper interne pour accéder au buffer
    pub(crate) fn with_inner<F, R>(&self, f: F) -> LyxalResult<R>
    where
        F: FnOnce(&mut DynamicImage) -> LyxalResult<R>,
    {
        let mut guard = self.inner.lock().map_err(|_| LyxalError::LockError)?;
        f(&mut guard)
    }
}