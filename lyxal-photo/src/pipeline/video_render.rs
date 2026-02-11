use serde::{Deserialize, Serialize};
use std::process::Command;
use tempfile::NamedTempFile;
use std::io::Write;
use std::fs;
use crate::storage::StorageEngine;

#[derive(Deserialize)]
pub struct VideoRenderTarget {
    pub purpose: String,
    pub format: String,
    pub codec: Option<String>,
    pub height: Option<u32>,
    pub grid: Option<String>,
    pub duration: Option<u32>,
}

#[derive(Deserialize)]
pub struct VideoRenderJobPayload {
    pub task_name: String,
    pub file_id: String,
    pub asset_storage_key: String,
    pub targets: Vec<VideoRenderTarget>,
    pub dry_run: Option<bool>,
}

#[derive(Serialize)]
pub struct VideoRenderResultItem {
    pub purpose: String,
    pub format: String,
    pub width: u32,
    pub height: u32,
    pub storage_pointer: String,
}

#[derive(Serialize)]
pub struct VideoRenderWorkerOutput {
    #[serde(rename = "type")]
    pub r#type: String,
    pub task_name: String,
    pub file_id: String,
    pub status: String,
    pub error: Option<String>,
    pub renditions: Vec<VideoRenderResultItem>,
    pub duration_ms: u64,
    pub bytes_in: u64,
    pub bytes_out: u64,
}

pub struct VideoRenderWorker;

impl VideoRenderWorker {
    pub async fn execute(
        &self, 
        payload: VideoRenderJobPayload, 
        storage: &dyn StorageEngine
    ) -> Result<VideoRenderWorkerOutput, Box<dyn std::error::Error>> {
        let start_time = std::time::Instant::now();
        let mut results = Vec::new();
        let dry_run = payload.dry_run.unwrap_or(false);
        let mut bytes_out = 0;

        // 1. Download original video
        let bytes = storage.get_bytes(&payload.asset_storage_key).await?;
        let bytes_in = bytes.len() as u64;
        
        // 2. Save to temp file
        let mut temp_input = NamedTempFile::new()?;
        temp_input.write_all(&bytes)?;
        let input_path = temp_input.path();

        // 3. Process each target with FFmpeg
        for target in payload.targets {
            let temp_output = NamedTempFile::new()?;
            let output_path = temp_output.path();
            
            if !dry_run {
                let mut cmd = Command::new("ffmpeg");
                cmd.arg("-i").arg(input_path).arg("-y");

                match target.purpose.as_str() {
                    "preview" => {
                        cmd.args(&["-c:v", "libx264", "-crf", "23", "-vf", "scale=-2:720", "-preset", "fast", "-c:a", "aac", "-b:a", "128k"]);
                    }
                    "stream" => {
                        cmd.args(&["-c:v", "libx265", "-crf", "28", "-vf", "scale=-2:1080", "-preset", "fast", "-c:a", "aac", "-b:a", "128k"]);
                    }
                    "storyboard" => {
                        cmd.args(&["-vf", "fps=1/10,tile=5x5", "-frames:v", "1"]);
                    }
                    "animated_thumb" => {
                        cmd.args(&["-t", "3", "-vf", "scale=320:-1", "-c:v", "libwebp", "-lossless", "0", "-compression_level", "6", "-q:v", "50", "-loop", "0"]);
                    }
                    _ => continue,
                }

                let output_file_path = output_path.to_str().ok_or("Invalid output path")?;
                cmd.arg(output_file_path);

                let status = cmd.status()?;
                if !status.success() {
                    return Err(format!("FFmpeg failed for purpose: {}", target.purpose).into());
                }
            }

            // Get output size
            if let Ok(metadata) = fs::metadata(output_path) {
                bytes_out += metadata.len();
            }

            // 4. Upload results
            let storage_path = format!("renditions/{}/{}.{}", payload.file_id, target.purpose, target.format);
            let mime = if target.format == "mp4" { "video/mp4" } else { "image/webp" };
            
            let final_key = if !dry_run {
                storage.put_file(&storage_path, output_path, mime).await?
            } else {
                format!("dry_run://{}", storage_path)
            };

            results.push(VideoRenderResultItem {
                purpose: target.purpose,
                format: target.format,
                width: 0, // In prod, read metadata
                height: target.height.unwrap_or(0),
                storage_pointer: final_key,
            });
        }

        Ok(VideoRenderWorkerOutput {
            r#type: "lyxal.video.render.output".to_string(),
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
