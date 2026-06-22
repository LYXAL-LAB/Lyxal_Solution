use crate::utils::to_bytes::to_bytes;
pub const DEFAULT_MAX_ASSETS: usize = 50;

pub struct AssetSchema;
impl AssetSchema {
    pub fn get_max_size_bytes(mb: &str) -> u64 {
        to_bytes(mb)
    }
}

