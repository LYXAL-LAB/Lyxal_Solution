use crate::core::LyxalImage;
use crate::error::{LyxalError, LyxalResult};
use tract_onnx::prelude::*;

// Structure qui garde le modèle chargé (Singleton conseillé dans Surreal)
pub struct FaceDetector {
    model: SimplePlan<TypedFact, Box<dyn TypedOp>, Graph<TypedFact, Box<dyn TypedOp>>>,
}

impl FaceDetector {
    pub fn new(model_bytes: &[u8]) -> LyxalResult<Self> {
        let model = tract_onnx::onnx()
            .model_for_read(&mut std::io::Cursor::new(model_bytes))
            .map_err(|e| LyxalError::ModelError(e.to_string()))?
            .into_optimized()
            .map_err(|e| LyxalError::ModelError(e.to_string()))?
            .into_runnable()
            .map_err(|e| LyxalError::ModelError(e.to_string()))?;
        
        Ok(Self { model })
    }

    // Retourne (x, y, w, h)
    pub fn detect_primary_face(&self, img: &LyxalImage) -> LyxalResult<Option<(u32, u32, u32, u32)>> {
        // Logique simplifiée pour l'exemple
        // 1. Resize pour le modèle
        // 2. To Tensor
        // 3. Run
        // 4. Parse output
        // TODO: Implémenter logic spécifique au modèle ONNX choisi (ex: UltraFace)
        Ok(Some((100, 100, 200, 200))) // Stub
    }
}

impl LyxalImage {
    pub fn smart_crop(&mut self, detector: &FaceDetector, w: u32, h: u32) -> LyxalResult<()> {
        let face = detector.detect_primary_face(self)?;
        if let Some((fx, fy, fw, fh)) = face {
            let cx = fx + fw / 2;
            let cy = fy + fh / 2;
            let x = cx.saturating_sub(w / 2);
            let y = cy.saturating_sub(h / 2);
            self.crop(x, y, w, h)?;
        } else {
            // Centre par défaut
            let (iw, ih) = self.with_inner(|i| Ok((i.width(), i.height())))?;
            let x = (iw - w) / 2;
            let y = (ih - h) / 2;
            self.crop(x, y, w, h)?;
        }
        Ok(())
    }
}