use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};
use uuid::Uuid;

// =============================================================================
// 1. TIMELINE & LISTS
// =============================================================================

#[derive(Serialize, Deserialize, Debug)]
pub struct PhotoTimelineItem {
    pub id: String, // photo:uuid
    pub title: String,
    pub taken_at: DateTime<Utc>,
    pub thumb_url: Option<String>,
    pub aspect_ratio: f32,
    pub photo_type: String, // image|video|live
    pub duration_sec: Option<f32>,
    pub has_geo: bool,
    pub is_favorite: bool,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct TimelineResponse {
    pub items: Vec<PhotoTimelineItem>,
    pub next_cursor: Option<String>,
}

// =============================================================================
// 2. PHOTO DETAILS
// =============================================================================

#[derive(Serialize, Deserialize, Debug)]
pub struct PhotoDetail {
    pub id: String,
    pub title: String,
    pub caption: Option<String>,
    pub taken_at: DateTime<Utc>,
    pub width: u32,
    pub height: u32,
    pub file_size: u64,
    pub photo_type: String,
    
    // Media URLs
    pub preview_url: Option<String>, // High res
    pub original_url: Option<String>, // Download
    pub video_stream_url: Option<String>, // HLS/MP4

    // Context
    pub location: Option<LocationDTO>,
    pub camera: Option<CameraDTO>,
    
    // AI
    pub faces: Vec<FaceDTO>,
    pub labels: Vec<String>,
    
    // Status
    pub integrity_status: String, // ok|processing|error
}

#[derive(Serialize, Deserialize, Debug)]
pub struct LocationDTO {
    pub name: String,
    pub city: Option<String>,
    pub country: String,
    pub lat: f64,
    pub lon: f64,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct CameraDTO {
    pub make: String,
    pub model: String,
    pub lens: Option<String>,
    pub iso: Option<u32>,
    pub f_number: Option<f32>,
    pub exposure: Option<String>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct FaceDTO {
    pub id: String,
    pub person_id: Option<String>,
    pub person_name: Option<String>,
    pub box_x: f32,
    pub box_y: f32,
    pub box_w: f32,
    pub box_h: f32,
}

// =============================================================================
// 3. PEOPLE & CLUSTERS
// =============================================================================

#[derive(Serialize, Deserialize, Debug)]
pub struct PersonDTO {
    pub id: String,
    pub name: String,
    pub face_count: u32,
    pub cover_photo_url: Option<String>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct UnidentifiedClusterDTO {
    pub cluster_id: Uuid,
    pub face_count: u32,
    pub cover_face_url: Option<String>, // Crop of the face
    pub samples: Vec<String>, // URLs of sample photos
}

// =============================================================================
// 4. SEARCH
// =============================================================================

#[derive(Serialize, Deserialize, Debug)]
pub struct SearchRequest {
    pub q: Option<String>,
    pub from_date: Option<DateTime<Utc>>,
    pub to_date: Option<DateTime<Utc>>,
    pub location: Option<String>,
    pub person_id: Option<String>,
    pub label: Option<String>,
    pub limit: usize,
    pub offset: usize,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct SearchResult {
    pub items: Vec<PhotoTimelineItem>,
    pub total_estimated: usize,
}

// =============================================================================
// 5. UPLOAD & INGESTION
// =============================================================================

#[derive(Serialize, Deserialize, Debug)]
pub struct UploadRequest {
    pub filename: String,
    pub size: u64,
    pub mime: String,
    pub hash: String, // Client-side hash for dedup check
    pub device_id: Option<String>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct UploadResponse {
    pub upload_url: String, // Where to PUT bytes (signed URL)
    pub asset_id: String,
    pub is_duplicate: bool,
}

// =============================================================================
// 6. SYNC PROTOCOL (Lyxal Sync)
// =============================================================================

#[derive(Serialize, Deserialize, Debug)]
pub struct SyncRequest {
    pub since_cursor: String,
    pub limit: usize,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct SyncEvent {
    pub id: String, // Event ID
    pub action: String, // created|updated|deleted
    pub entity_type: String, // photo|album|person
    pub entity_id: String,
    pub timestamp: DateTime<Utc>,
    pub payload: Option<serde_json::Value>, // Minimal diff
}

#[derive(Serialize, Deserialize, Debug)]
pub struct SyncResponse {
    pub events: Vec<SyncEvent>,
    pub next_cursor: String,
    pub has_more: bool,
}
