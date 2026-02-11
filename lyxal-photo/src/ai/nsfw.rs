use anyhow::Result;
use image::DynamicImage;

pub struct NsfwDetector;

impl NsfwDetector {
    pub fn detect(&self, _img: &DynamicImage) -> Result<f32> {
        // Simulé V1
        Ok(0.01)
    }
}
