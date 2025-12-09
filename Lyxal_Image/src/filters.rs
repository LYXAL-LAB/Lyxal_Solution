use crate::core::LyxalImage;
use crate::error::LyxalResult;

impl LyxalImage {
    pub fn blur(&mut self, sigma: f32) -> LyxalResult<()> {
        self.with_inner(|img| {
            *img = img.blur(sigma);
            Ok(())
        })
    }

    pub fn grayscale(&mut self) -> LyxalResult<()> {
        self.with_inner(|img| {
            *img = img.grayscale();
            Ok(())
        })
    }
    
    // Placeholder pour future implémentation LUT (complexe)
    pub fn apply_lut(&mut self, _lut_path: &str) -> LyxalResult<()> {
        // TODO: Charger .cube file et mapper les pixels
        Ok(())
    }
}