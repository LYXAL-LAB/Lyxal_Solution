use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum AlbumType {
    Album,
    Folder,
    Moment,
    State,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Album {
    pub uid: String,
    pub slug: String,
    pub title: String,
    pub album_type: AlbumType,
    pub order: String, // ex: "chronological"
}

impl Album {
    pub fn new(uid: String, slug: String, title: String) -> Self {
        Self {
            uid,
            slug,
            title,
            album_type: AlbumType::Album,
            order: String::from("chronological"),
        }
    }
}
