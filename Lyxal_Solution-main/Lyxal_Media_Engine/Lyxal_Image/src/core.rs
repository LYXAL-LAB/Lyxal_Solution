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
            .map_err(|e| LyxalError::Decode(image::ImageError::IoError(e)))?;
        
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
    
    pub fn new_empty(w: u32, h: u32) -> Self {
        // Create transparent image
        let buffer = image::RgbaImage::new(w, h);
        Self {
            inner: Arc::new(Mutex::new(image::DynamicImage::ImageRgba8(buffer))),
            format: image::ImageFormat::Png, // Default
        }
    }
    
    pub fn from_rgba(buffer: image::RgbaImage) -> Self {
        Self {
            inner: Arc::new(Mutex::new(image::DynamicImage::ImageRgba8(buffer))),
            format: image::ImageFormat::Png,
        }
    }
    
    pub fn get_dimensions(&self) -> (u32, u32) {
        use image::GenericImageView;
        let guard = self.inner.lock().unwrap();
        guard.dimensions()
    }
    
    pub fn to_rgba8_cloned(&self) -> image::RgbaImage {
        let guard = self.inner.lock().unwrap();
        guard.to_rgba8()
    }
    
    // Implement clone properly if needed or rely on lightweight Arc clone
    // But here we want a 'deep clone' of content sometimes
    pub fn clone(&self) -> Self {
        let guard = self.inner.lock().unwrap();
        let img_clone = guard.clone(); // DynamicImage clone is deep
        Self {
            inner: Arc::new(Mutex::new(img_clone)),
            format: self.format,
        }
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

    pub fn width(&self) -> u32 {
        use image::GenericImageView;
        self.inner.lock().unwrap().width()
    }

    pub fn height(&self) -> u32 {
        use image::GenericImageView;
        self.inner.lock().unwrap().height()
    }

    pub fn to_rgba8(&self) -> image::RgbaImage {
        self.inner.lock().unwrap().to_rgba8()
    }

    pub fn replace_buffer(&mut self, new_img: DynamicImage) {
        let mut guard = self.inner.lock().unwrap();
        *guard = new_img;
    }
}