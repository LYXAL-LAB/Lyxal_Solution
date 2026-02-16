use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AnimationOptions {
    pub duration: f64,
    pub delay: f64,
    pub ease: String,
    pub stagger: Option<f64>,
}

