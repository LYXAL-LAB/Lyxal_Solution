use serde::{Deserialize, Serialize};
use crate::storage::StorageEngine;
use crate::ai::{FaceDetector, FaceEmbedder, LabelClassifier, NsfwDetector};
use crate::ai::vision::crop_to_box;
use image::DynamicImage;

#[derive(Deserialize)]
pub struct AiAnalysisTargets {
    pub faces: bool,
    pub labels: bool,
    pub nsfw: bool,
}

#[derive(Deserialize)]
pub struct AiJobPayload {
    pub task_name: String,
    pub photo_id: String,
    pub primary_file_id: String,
    pub asset_storage_key: String,
    pub image_mime: String,
    pub analysis_targets: AiAnalysisTargets,
    pub version: String,
    pub dry_run: Option<bool>,
}

#[derive(Serialize)]
pub struct AiFaceResult {
    pub x: f32,
    pub y: f32,
    pub w: f32,
    pub h: f32,
    pub uncertainty: f32,
    pub embedding_512: Vec<f32>,
    pub cluster_hint: Option<String>,
}

#[derive(Serialize)]
pub struct AiLabelResult {
    pub name: String,
    pub uncertainty: f32,
    pub nsfw: f32,
}

#[derive(Serialize)]
pub struct AiWorkerOutput {
    #[serde(rename = "type")]
    pub r#type: String,
    pub task_name: String,
    pub photo_id: String,
    pub primary_file_id: String,
    pub status: String,
    pub error: Option<String>,
    pub faces: Vec<AiFaceResult>,
    pub labels: Vec<AiLabelResult>,
    pub nsfw_global: f32,
    pub duration_ms: u64,
    pub bytes_in: u64,
    pub bytes_out: u64,
}

pub struct AiWorker {
    pub face_detector: Option<FaceDetector>,
    pub face_embedder: Option<FaceEmbedder>,
    pub label_classifier: Option<LabelClassifier>,
    pub nsfw_detector: NsfwDetector,
}

impl AiWorker {
    pub async fn execute(
        &self, 
        payload: AiJobPayload, 
        storage: &dyn StorageEngine
    ) -> Result<AiWorkerOutput, Box<dyn std::error::Error>> {
        let start_time = std::time::Instant::now();
        let dry_run = payload.dry_run.unwrap_or(false);

        // 1. Download original
        let bytes = storage.get_bytes(&payload.asset_storage_key).await?;
        let bytes_in = bytes.len() as u64;

        // 2. Decode image
        let img = if !dry_run {
            image::load_from_memory(&bytes)?
        } else {
            DynamicImage::new_rgba8(1, 1)
        };

        let mut faces_results = Vec::new();
        let mut labels_results = Vec::new();
        let mut nsfw_global = 0.0;

        if !dry_run {
            // 3. Face Analysis
            if payload.analysis_targets.faces {
                if let Some(detector) = &self.face_detector {
                    let boxes = detector.detect(&img)?;
                    if let Some(embedder) = &self.face_embedder {
                        for b in boxes {
                            let face_img = crop_to_box(&img, b.x, b.y, b.w, b.h);
                            let embedding = embedder.embed(&face_img)?;
                            
                            faces_results.push(AiFaceResult {
                                x: b.x, y: b.y, w: b.w, h: b.h,
                                uncertainty: 1.0 - b.score,
                                embedding_512: embedding,
                                cluster_hint: None,
                            });
                        }
                    }
                }
            }

            // 4. Label Analysis
            if payload.analysis_targets.labels {
                if let Some(classifier) = &self.label_classifier {
                    let results = classifier.classify(&img)?;
                    for r in results {
                        labels_results.push(AiLabelResult {
                            name: r.name,
                            uncertainty: 1.0 - r.score,
                            nsfw: 0.0,
                        });
                    }
                }
            }

            // 5. NSFW Analysis
            if payload.analysis_targets.nsfw {
                nsfw_global = self.nsfw_detector.detect(&img)?;
            }
        }

        Ok(AiWorkerOutput {
            r#type: "lyxal.photo.ai.output".to_string(),
            task_name: payload.task_name,
            photo_id: payload.photo_id,
            primary_file_id: payload.primary_file_id,
            status: "completed".to_string(),
            error: None,
            faces: faces_results,
            labels: labels_results,
            nsfw_global,
            duration_ms: start_time.elapsed().as_millis() as u64,
            bytes_in,
            bytes_out: 0, // AI produces metadata only, no file output
        })
    }
}
