use serde::{Deserialize, Serialize};
use crate::storage::StorageEngine;
use crate::render::RenderEngine;
use image::DynamicImage;

#[derive(Deserialize)]
pub struct RenderTarget {
    pub purpose: String,
    pub format: String,
    pub size: u32,
}

#[derive(Deserialize)]
pub struct RenderJobPayload {
    pub task_name: String,
    pub file_id: String,
    pub asset_storage_key: String,
    pub targets: Vec<RenderTarget>,
    pub dry_run: Option<bool>,
}

#[derive(Serialize)]
pub struct RenderResultItem {
    pub purpose: String,
    pub format: String,
    pub width: u32,
    pub height: u32,
    pub storage_pointer: String,
}

#[derive(Serialize)]
pub struct RenderWorkerOutput {
    #[serde(rename = "type")]
    pub r#type: String,
    pub task_name: String,
    pub file_id: String,
    pub status: String,
    pub error: Option<String>,
    pub renditions: Vec<RenderResultItem>,
    pub duration_ms: u64,
    pub bytes_in: u64,
    pub bytes_out: u64,
}

pub struct RenditionWorker;

impl RenditionWorker {
    pub async fn execute(
        &self, 
        payload: RenderJobPayload, 
        storage: &dyn StorageEngine
    ) -> Result<RenderWorkerOutput, Box<dyn std::error::Error>> {
        let start_time = std::time::Instant::now();
        let mut results = Vec::new();
        let dry_run = payload.dry_run.unwrap_or(false);
        let mut bytes_out = 0;

        // 1. Download original
        let bytes = storage.get_bytes(&payload.asset_storage_key).await?;
        let bytes_in = bytes.len() as u64;

        // 2. Decode image
        let img = if !dry_run {
            RenderEngine::decode(&bytes)?
        } else {
            DynamicImage::new_rgba8(1, 1)
        };

        // 3. Process targets
        for target in payload.targets {
            let processed_img = if !dry_run {
                RenderEngine::resize(&img, target.size)?
            } else {
                img.clone()
            };

            let encoded_bytes = if !dry_run {
                match target.format.as_str() {
                    "webp" => RenderEngine::encode_webp(&processed_img, 80.0)?,
                    "avif" => RenderEngine::encode_avif(&processed_img, 80.0)?,
                    _ => return Err(format!("Unsupported format: {}", target.format).into()),
                }
            } else {
                Vec::new()
            };

            bytes_out += encoded_bytes.len() as u64;

            let storage_path = format!("renditions/{}/{}.{}", payload.file_id, target.purpose, target.format);
            let mime = format!("image/{}", target.format);
            
            let final_key = if !dry_run {
                storage.put_bytes(&storage_path, encoded_bytes, &mime).await?
            } else {
                format!("dry_run://{}", storage_path)
            };
            
            results.push(RenderResultItem {
                purpose: target.purpose,
                format: target.format,
                width: processed_img.width(),
                height: processed_img.height(), 
                storage_pointer: final_key,
            });
        }

        Ok(RenderWorkerOutput {
            r#type: "lyxal.photo.render.output".to_string(),
            task_name: payload.task_name,
            file_id: payload.file_id,
            status: "completed".to_string(),
            error: None,
            renditions: results,
            duration_ms: start_time.elapsed().as_millis() as u64,
            bytes_in,
            bytes_out,
        })
    }
}
