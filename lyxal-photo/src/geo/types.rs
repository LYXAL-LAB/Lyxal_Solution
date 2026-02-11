use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlaceResult {
    pub provider: String,
    pub provider_id: String,
    pub name: String,
    pub display_name: String,
    pub city: Option<String>,
    pub state: Option<String>,
    pub country: String,
    pub country_code: String,
    pub postcode: Option<String>,
    pub road: Option<String>,
    pub lat: f64,
    pub lon: f64,
}
