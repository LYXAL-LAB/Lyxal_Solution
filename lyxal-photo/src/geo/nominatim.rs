use async_trait::async_trait;
use anyhow::{Result, anyhow};
use reqwest::Client;
use serde::Deserialize;
use super::{GeoProvider, PlaceResult};

pub struct NominatimProvider {
    client: Client,
    endpoint: String,
}

#[derive(Deserialize)]
struct NominatimResponse {
    place_id: u64,
    osm_id: u64,
    osm_type: String,
    display_name: String,
    address: NominatimAddress,
    lat: String,
    lon: String,
}

#[derive(Deserialize)]
struct NominatimAddress {
    #[serde(alias = "village", alias = "town", alias = "city_district")]
    city: Option<String>,
    state: Option<String>,
    country: String,
    country_code: String,
    postcode: Option<String>,
    road: Option<String>,
    #[serde(alias = "house_number")]
    name: Option<String>,
}

impl NominatimProvider {
    pub fn new(endpoint: String) -> Self {
        Self {
            client: Client::builder()
                .user_agent("LyxalPhoto/1.0")
                .build()
                .unwrap(),
            endpoint,
        }
    }
}

#[async_trait]
impl GeoProvider for NominatimProvider {
    async fn reverse(&self, lat: f64, lon: f64) -> Result<PlaceResult> {
        let url = format!("{}/reverse?format=jsonv2&lat={}&lon={}", self.endpoint, lat, lon);
        
        let resp = self.client.get(url)
            .send()
            .await?;

        if !resp.status().is_success() {
            return Err(anyhow!("Nominatim request failed: {}", resp.status()));
        }

        let data: NominatimResponse = resp.json().await?;

        Ok(PlaceResult {
            provider: "nominatim".to_string(),
            provider_id: format!("{}:{}", data.osm_type, data.osm_id),
            name: data.address.name.unwrap_or_else(|| data.address.road.clone().unwrap_or_default()),
            display_name: data.display_name,
            city: data.address.city,
            state: data.address.state,
            country: data.address.country,
            country_code: data.address.country_code,
            postcode: data.address.postcode,
            road: data.address.road,
            lat: data.lat.parse()?,
            lon: data.lon.parse()?,
        })
    }
}
