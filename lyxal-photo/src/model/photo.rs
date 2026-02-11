use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum PhotoType {
    Image,
    Video,
    Live,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum PlaceStatus {
    Pending,
    Resolved,
    Failed,
    Disabled,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Photo {
    pub uid: String,
    pub photo_type: PhotoType,
    pub title: String,
    pub caption: String,
    pub taken_at: DateTime<Utc>,
    pub taken_at_local: DateTime<Utc>,
    pub quality: u8, // 0-7
    pub resolution: u32,
    pub lat: Option<f64>,
    pub lng: Option<f64>,
    pub alt: Option<f64>,
    pub place_uid: Option<String>,
    pub place_status: PlaceStatus,
    pub details: PhotoDetails,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub edited_at: Option<DateTime<Utc>>,
    pub indexed_at: Option<DateTime<Utc>>,
    pub deleted_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize, Default)]
pub struct PhotoDetails {
    pub keywords: Vec<String>,
    pub artist: String,
}

impl Photo {
    pub fn new(uid: String, title: String, taken_at: DateTime<Utc>) -> Self {
        Self {
            uid,
            photo_type: PhotoType::Image,
            title,
            caption: String::new(),
            taken_at,
            taken_at_local: taken_at,
            quality: 0,
            resolution: 0,
            lat: None,
            lng: None,
            alt: None,
            place_uid: None,
            place_status: PlaceStatus::Pending,
            details: PhotoDetails::default(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            edited_at: None,
            indexed_at: None,
            deleted_at: None,
        }
    }
}
