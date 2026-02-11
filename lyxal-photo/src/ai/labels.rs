use ort::{Session, Value};
use anyhow::Result;
use std::sync::Arc;
use crate::ai::vision::preprocess_image;
use image::DynamicImage;

pub struct LabelClassifier {
    session: Arc<Session>,
}

pub struct LabelResult {
    pub name: String,
    pub score: f32,
}

impl LabelClassifier {
    pub fn new(session: Arc<Session>) -> Self {
        Self { session }
    }

    pub fn classify(&self, img: &DynamicImage) -> Result<Vec<LabelResult>> {
        let input = preprocess_image(img, 224, 224);
        let input_tensor = Value::from_array(self.session.allocator(), &input)?;
        
        let outputs = self.session.run(vec![input_tensor])?;
        
        // Simulé pour M4
        let results = vec![
            LabelResult { name: "Nature".to_string(), score: 0.92 },
            LabelResult { name: "Montagne".to_string(), score: 0.85 },
        ];
        
        Ok(results)
    }
}
