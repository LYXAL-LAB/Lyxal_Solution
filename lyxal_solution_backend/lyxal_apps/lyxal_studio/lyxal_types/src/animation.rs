use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum RangeUnitValue {
    Unit { value: f64, unit: String },
    Unparsed { value: String },
    Var { value: String },
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum DurationUnitValue {
    Unit { value: f64, unit: String },
    Var { value: String },
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(untagged)]
pub enum IterationsUnitValue {
    Number(f64),
    Infinite(String), // "infinite"
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum InsetUnitValue {
    Range(RangeUnitValue),
    Keyword { value: String }, // "auto"
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct AnimationKeyframe {
    pub offset: Option<f64>,
    pub styles: HashMap<String, serde_json::Value>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct KeyframeEffectOptions {
    pub easing: Option<String>,
    pub fill: Option<String>,
    pub duration: Option<DurationUnitValue>,
    pub delay: Option<DurationUnitValue>,
    pub iterations: Option<IterationsUnitValue>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ScrollRangeOptions {
    pub range_start: Option<(String, RangeUnitValue)>,
    pub range_end: Option<(String, RangeUnitValue)>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ViewRangeOptions {
    pub range_start: Option<(String, RangeUnitValue)>,
    pub range_end: Option<(String, RangeUnitValue)>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct BaseAnimation {
    pub name: Option<String>,
    pub description: Option<String>,
    pub enabled: Option<Vec<(String, bool)>>,
    pub keyframes: Vec<AnimationKeyframe>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ScrollAnimation {
    #[serde(flatten)]
    pub base: BaseAnimation,
    pub timing: serde_json::Value, // Combination of KeyframeEffectOptions and ScrollRangeOptions
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ViewAnimation {
    #[serde(flatten)]
    pub base: BaseAnimation,
    pub timing: serde_json::Value, // Combination of KeyframeEffectOptions and ViewRangeOptions
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum AnimationAction {
    Scroll {
        source: Option<String>,
        axis: Option<String>,
        animations: Vec<ScrollAnimation>,
        is_pinned: Option<bool>,
        debug: Option<bool>,
    },
    View {
        subject: Option<String>,
        axis: Option<String>,
        animations: Vec<ViewAnimation>,
        inset_start: Option<InsetUnitValue>,
        inset_end: Option<InsetUnitValue>,
        is_pinned: Option<bool>,
        debug: Option<bool>,
    },
}

