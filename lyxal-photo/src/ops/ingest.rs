use crate::model::{Asset, File, Photo};
use chrono::Utc;

pub struct IngestOp;

impl IngestOp {
    /// Simule l'ingestion d'un fichier physique
    pub fn ingest_file(
        hash: String,
        size: u64,
        mime: String,
        name: String,
        path: String,
    ) -> (Asset, File) {
        let storage_key = format!("vault/{}/{}", Utc::now().format("%Y/%m"), name);
        let asset = Asset::new(hash.clone(), size, mime, storage_key);
        
        let file_uid = format!("f_{}", uuid::Uuid::new_v4().to_string());
        let mut file = File::new(file_uid, hash, path, name);
        file.origin = String::from("ingest_op");
        
        (asset, file)
    }

    /// Simule le pairing avec une photo existante ou nouvelle
    pub fn pair_with_photo(file: &mut File, existing_photo: Option<Photo>) -> Photo {
        if let Some(photo) = existing_photo {
            file.photo_uid = Some(photo.uid.clone());
            photo
        } else {
            let photo_uid = format!("p_{}", uuid::Uuid::new_v4().to_string());
            let title = file.name.split('.').next().unwrap_or("Untitled").to_string();
            let photo = Photo::new(photo_uid.clone(), title, Utc::now());
            file.photo_uid = Some(photo_uid);
            photo
        }
    }
}
