pub mod types;
pub mod nominatim;
pub mod cache;

use async_trait::async_trait;
use anyhow::Result;
pub use types::PlaceResult;

#[async_trait]
pub trait GeoProvider: Send + Sync {
    async fn reverse(&self, lat: f64, lon: f64) -> Result<PlaceResult>;
}
