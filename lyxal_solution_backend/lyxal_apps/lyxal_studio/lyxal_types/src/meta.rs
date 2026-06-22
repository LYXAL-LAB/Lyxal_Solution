use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub enum ComponentCategory {
    General,
    Typography,
    Media,
    Animations,
    Data,
    Forms,
    Localization,
    Radix,
    Xml,
    Other,
    Hidden,
    Internal,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub enum ContentCategory {
    Instance,
    None,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ContentModel {
    pub category: ContentCategory,
    pub children: Vec<String>,
    pub descendants: Option<Vec<String>>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ComponentState {
    pub selector: String,
    pub label: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PresetStyleDecl {
    pub state: Option<String>,
    pub property: String,
    pub value: serde_json::Value,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "control", rename_all = "kebab-case")]
pub enum PropMeta {
    Tag { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, options: Vec<String> },
    Number { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<f64> },
    Range { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<f64> },
    Text { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<String>, rows: Option<u32> },
    Resource { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<String> },
    Code { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, language: String, default_value: Option<String> },
    Codetext { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<String> },
    Color { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<String> },
    Boolean { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<bool> },
    Radio { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<String>, options: Vec<String> },
    #[serde(rename = "inline-radio")]
    InlineRadio { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<String>, options: Vec<String> },
    Select { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<String>, options: Vec<String> },
    #[serde(rename = "multi-select")]
    MultiSelect { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<Vec<String>>, options: Vec<String> },
    Check { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<Vec<String>>, options: Vec<String> },
    #[serde(rename = "inline-check")]
    InlineCheck { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<Vec<String>>, options: Vec<String> },
    File { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<String>, accept: Option<String> },
    Url { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<String> },
    Json { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<serde_json::Value> },
    Date { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<String> },
    Action { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String },
    TextContent { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String, default_value: Option<String> },
    AnimationAction { label: Option<String>, description: Option<String>, required: bool, #[serde(rename = "type")] prop_type: String },
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WsComponentMeta {
    pub category: Option<ComponentCategory>,
    pub content_model: Option<ContentModel>,
    pub index_within_ancestor: Option<String>,
    pub label: Option<String>,
    pub description: Option<String>,
    pub icon: Option<String>,
    pub preset_style: Option<HashMap<String, Vec<PresetStyleDecl>>>,
    pub states: Option<Vec<ComponentState>>,
    pub order: Option<f64>,
    pub initial_props: Option<Vec<String>>,
    pub props: Option<HashMap<String, PropMeta>>,
}

