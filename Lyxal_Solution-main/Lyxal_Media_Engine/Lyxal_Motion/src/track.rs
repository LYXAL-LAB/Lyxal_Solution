use serde::{Deserialize, Serialize};
use crate::keyframe::Keyframe;
use crate::value::MotionValue;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MotionTrack {
    pub property: String,
    pub keyframes: Vec<Keyframe>,
}

impl MotionTrack {
    pub fn new(property: String, mut keyframes: Vec<Keyframe>) -> Self {
        // Sort keyframes by time
        keyframes.sort_by(|a, b| a.time.partial_cmp(&b.time).unwrap());
        Self { property, keyframes }
    }

    pub fn get_value(&self, t: f32) -> Option<MotionValue> {
        if self.keyframes.is_empty() {
            return None;
        }

        // Handle boundaries
        if t <= self.keyframes.first()?.time {
            return Some(self.keyframes.first()?.value.clone());
        }
        if t >= self.keyframes.last()?.time {
            return Some(self.keyframes.last()?.value.clone());
        }

        // Find binary search or linear scan (vector is usually small for UI motion)
        // Find segment
        let mut k1 = &self.keyframes[0];
        let mut k2 = &self.keyframes[0];
        
        for k in &self.keyframes {
            if k.time > t {
                k2 = k;
                break;
            }
            k1 = k;
        }
        
        // k1.time <= t < k2.time
        let duration = k2.time - k1.time;
        if duration <= 0.00001 {
            return Some(k1.value.clone());
        }
        
        let local_t = (t - k1.time) / duration;
        let eased_t = k1.easing.sample(local_t);
        
        k1.value.lerp(&k2.value, eased_t)
    }
}
