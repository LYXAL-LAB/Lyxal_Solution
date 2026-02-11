use serde::{Deserialize, Serialize};
use crate::value::MotionValue;
use crate::easing::EasingCurve;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Keyframe {
    pub time: f32, // Normalized 0.0 to 1.0 (or absolute seconds? Requirement says "timestamps normalized (0.0 -> 1.0)")
    pub value: MotionValue,
    pub easing: EasingCurve,
}
