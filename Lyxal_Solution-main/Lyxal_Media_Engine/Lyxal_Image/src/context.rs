#[derive(Clone, Debug)]
pub struct ImageContext {
    pub max_width: u32,
    pub max_height: u32,
    pub max_pixels: u64, // Protection "Zip Bomb"
    pub max_steps: usize,
    pub allow_ml: bool,
}

impl Default for ImageContext {
    fn default() -> Self {
        Self {
            max_width: 8192,
            max_height: 8192,
            max_pixels: 50_000_000, // ~50MP
            max_steps: 20,
            allow_ml: true,
        }
    }
}