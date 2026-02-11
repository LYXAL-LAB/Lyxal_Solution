use serde::{Deserialize, Serialize};
use uuid::Uuid;
use crate::storage::StorageEngine;

#[derive(Deserialize)]
pub struct FaceInput {
    pub id: String,
    pub embedding: Vec<f32>,
}

#[derive(Deserialize)]
pub struct ClusterJobPayload {
    pub task_name: String,
    pub photo_id: String,
    pub primary_file_id: String,
    pub faces: Vec<FaceInput>,
    pub metric: String,
    pub threshold: f32,
    pub min_cluster: usize,
    pub version: String,
    pub dry_run: Option<bool>,
}

#[derive(Serialize)]
pub struct ClusterAssignment {
    pub face_id: String,
    pub cluster_id: Uuid,
}

#[derive(Serialize)]
pub struct ClusterWorkerOutput {
    #[serde(rename = "type")]
    pub r#type: String,
    pub task_name: String,
    pub photo_id: String,
    pub status: String,
    pub error: Option<String>,
    pub clusters: Vec<ClusterAssignment>,
    pub duration_ms: u64,
    pub bytes_in: u64,
    pub bytes_out: u64,
}

pub struct ClusterWorker;

impl ClusterWorker {
    pub async fn execute(
        &self, 
        payload: ClusterJobPayload,
        _storage: &dyn StorageEngine
    ) -> Result<ClusterWorkerOutput, Box<dyn std::error::Error>> {
        let start_time = std::time::Instant::now();
        let mut clusters = Vec::new();

        // 1. Logique de Clustering (Simulation DBSCAN)
        for face in &payload.faces {
            let cluster_id = Uuid::new_v4();
            clusters.push(ClusterAssignment {
                face_id: face.id.clone(),
                cluster_id,
            });
        }

        Ok(ClusterWorkerOutput {
            r#type: "lyxal.photo.faces.cluster.output".to_string(),
            task_name: payload.task_name,
            photo_id: payload.photo_id,
            status: "completed".to_string(),
            error: None,
            clusters,
            duration_ms: start_time.elapsed().as_millis() as u64,
            bytes_in: 0, // In-memory processing
            bytes_out: 0,
        })
    }
}
