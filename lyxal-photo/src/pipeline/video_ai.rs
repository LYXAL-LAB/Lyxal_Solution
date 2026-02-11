use serde::{Deserialize, Serialize};
use std::process::Command;
use tempfile::{NamedTempFile, tempdir};
use std::io::Write;
use std::fs;
use crate::storage::StorageEngine;
use crate::ai::{FaceDetector, FaceEmbedder, LabelClassifier, NsfwDetector};
use crate::ai::vision::crop_to_box;
use image::DynamicImage;

#[derive(Deserialize)]
pub struct VideoAiJobPayload {
    pub task_name: String,
    pub photo_id: String,
    pub primary_file_id: String,
    pub asset_storage_key: String,
    pub sampling_rate_sec: f32,
    pub dry_run: Option<bool>,
    pub max_frames: Option<usize>,
}

#[derive(Serialize)]
pub struct VideoAiFaceResult {
    pub timestamp_ms: u32,
    pub x: f32, pub y: f32, pub w: f32, pub h: f32,
    pub uncertainty: f32,
    pub embedding_512: Vec<f32>,
    pub cluster_hint: Option<String>,
}

#[derive(Serialize)]
pub struct VideoAiWorkerOutput {
    #[serde(rename = "type")]
    pub r#type: String,
    pub task_name: String,
    pub photo_id: String,
    pub primary_file_id: String,
    pub status: String,
    pub error: Option<String>,
    pub faces: Vec<VideoAiFaceResult>,
    pub duration_ms: u64,
    pub frames_processed: usize,
    pub bytes_in: u64,
    pub bytes_out: u64,
}

pub struct VideoAiWorker {
    pub face_detector: Option<FaceDetector>,
    pub face_embedder: Option<FaceEmbedder>,
    pub label_classifier: Option<LabelClassifier>,
    pub nsfw_detector: NsfwDetector,
}

impl VideoAiWorker {
    pub async fn execute(
        &self, 
        payload: VideoAiJobPayload, 
        storage: &dyn StorageEngine
    ) -> Result<VideoAiWorkerOutput, Box<dyn std::error::Error>> {
        let start_time = std::time::Instant::now();
        let dry_run = payload.dry_run.unwrap_or(false);
        let sampling_rate = payload.sampling_rate_sec.max(0.1);
        let max_frames = payload.max_frames.unwrap_or(600);

        // 1. Download original video
        let bytes = storage.get_bytes(&payload.asset_storage_key).await?;
        let bytes_in = bytes.len() as u64;
        
        // 2. Save to temp file
        let mut temp_input = NamedTempFile::new()?;
        temp_input.write_all(&bytes)?;
        let input_path = temp_input.path();

        // 3. Create temp dir for frames
        let tmp_dir = tempdir()?;
        let frame_pattern = tmp_dir.path().join("frame_%06d.jpg");

        let mut faces_results = Vec::new();
        let mut frames_processed = 0;

        if !dry_run {
            // 4. Extract frames with FFmpeg
            let status = Command::new("ffmpeg")
                .arg("-i").arg(input_path)
                .arg("-vf").arg(format!("fps=1/{}", sampling_rate))
                .arg("-vsync").arg("vfr")
                .arg(frame_pattern.to_str().unwrap())
                .status()?;

            if !status.success() {
                return Err("FFmpeg frame extraction failed".into());
            }

            // 5. Process each frame
            let mut entries: Vec<_> = fs::read_dir(tmp_dir.path())?
                .filter_map(|res| res.ok())
                .collect();
            entries.sort_by_key(|e| e.path());

            for (i, entry) in entries.into_iter().enumerate() {
                if i >= max_frames {
                    break;
                }

                let frame_path = entry.path();
                let frame_bytes = fs::read(&frame_path)?;
                let img = image::load_from_memory(&frame_bytes)?;
                let timestamp_ms = (i as f32 * sampling_rate * 1000.0) as u32;

                // Detect and Embed Faces
                if let Some(detector) = &self.face_detector {
                    let boxes = detector.detect(&img)?;
                    if let Some(embedder) = &self.face_embedder {
                        for b in boxes {
                            let face_img = crop_to_box(&img, b.x, b.y, b.w, b.h);
                            let embedding = embedder.embed(&face_img)?;
                            
                            faces_results.push(VideoAiFaceResult {
                                timestamp_ms,
                                x: b.x, y: b.y, w: b.w, h: b.h,
                                uncertainty: 1.0 - b.score,
                                embedding_512: embedding,
                                cluster_hint: None,
                            });
                        }
                    }
                }
                
                frames_processed += 1;
            }
        }

        Ok(VideoAiWorkerOutput {
            r#type: "lyxal.video.ai.output".to_string(),
            task_name: payload.task_name,
            photo_id: payload.photo_id,
            primary_file_id: payload.primary_file_id,
            status: "completed".to_string(),
            error: None,
            faces: faces_results,
            duration_ms: start_time.elapsed().as_millis() as u64,
            frames_processed,
            bytes_in,
            bytes_out: 0, // Metadata only
        })
    }
}
