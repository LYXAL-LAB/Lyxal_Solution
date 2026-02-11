use serde::{Deserialize, Serialize};
use crate::storage::StorageEngine;
use crate::geo::{GeoProvider, PlaceResult};

#[derive(Deserialize)]
pub struct LatLng {
    pub coordinates: [f64; 2], // [lon, lat]
}

#[derive(Deserialize)]
pub struct GeoJobPayload {
    pub task_name: String,
    pub photo_id: String,
    pub latlng: LatLng,
    pub dry_run: Option<bool>,
}

#[derive(Serialize)]
pub struct GeoWorkerOutput {
    #[serde(rename = "type")]
    pub r#type: String,
    pub task_name: String,
    pub photo_id: String,
    pub status: String,
    pub error: Option<String>,
    pub latlng: [f64; 2],
    pub place: Option<PlaceResult>,
    pub duration_ms: u64,
    pub bytes_in: u64,
    pub bytes_out: u64,
}

pub struct GeoWorker {
    pub provider: Box<dyn GeoProvider>,
}

impl GeoWorker {
    pub async fn execute(
        &self, 
        payload: GeoJobPayload, 
        _storage: &dyn StorageEngine
    ) -> Result<GeoWorkerOutput, Box<dyn std::error::Error>> {
        let start_time = std::time::Instant::now();
        let dry_run = payload.dry_run.unwrap_or(false);
        
        let lon = payload.latlng.coordinates[0];
        let lat = payload.latlng.coordinates[1];

        if dry_run {
            return Ok(GeoWorkerOutput {
                r#type: "lyxal.photo.geo.output".to_string(),
                task_name: payload.task_name,
                photo_id: payload.photo_id,
                status: "completed".to_string(),
                error: None,
                latlng: [lon, lat],
                place: None,
                duration_ms: start_time.elapsed().as_millis() as u64,
                bytes_in: 0,
                bytes_out: 0,
            });
        }

        match self.provider.reverse(lat, lon).await {
            Ok(result) => {
                Ok(GeoWorkerOutput {
                    r#type: "lyxal.photo.geo.output".to_string(),
                    task_name: payload.task_name,
                    photo_id: payload.photo_id,
                    status: "completed".to_string(),
                    error: None,
                    latlng: [lon, lat],
                    place: Some(result),
                    duration_ms: start_time.elapsed().as_millis() as u64,
                    bytes_in: 0, // External API call, no storage IO
                    bytes_out: 0,
                })
            }
            Err(e) => {
                Ok(GeoWorkerOutput {
                    r#type: "lyxal.photo.geo.output".to_string(),
                    task_name: payload.task_name,
                    photo_id: payload.photo_id,
                    status: "failed".to_string(),
                    error: Some(e.to_string()),
                    latlng: [lon, lat],
                    place: None,
                    duration_ms: start_time.elapsed().as_millis() as u64,
                    bytes_in: 0,
                    bytes_out: 0,
                })
            }
        }
    }
}
