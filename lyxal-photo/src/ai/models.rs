use ort::{Session, SessionBuilder, Environment};
use anyhow::Result;
use std::sync::Arc;
use std::path::Path;

pub struct ModelManager {
    pub face_detect: Arc<Session>,
    pub face_embed: Arc<Session>,
    pub labels: Arc<Session>,
}

impl ModelManager {
    pub fn load_from_dir(dir: &Path) -> Result<Self> {
        let env = Arc::new(Environment::builder().with_name("LyxalPhotoAI").build()?);
        
        let face_detect = SessionBuilder::new(&env)?
            .with_model_from_file(dir.join("retinaface.onnx"))?;
            
        let face_embed = SessionBuilder::new(&env)?
            .with_model_from_file(dir.join("arcface_512.onnx"))?;
            
        let labels = SessionBuilder::new(&env)?
            .with_model_from_file(dir.join("mobilenet_v2.onnx"))?;

        Ok(Self {
            face_detect: Arc::new(face_detect),
            face_embed: Arc::new(face_embed),
            labels: Arc::new(labels),
        })
    }
}
