use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum StyleValue {
    Unit {
        unit: String,
        value: f64,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    Keyword {
        value: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    Unparsed {
        value: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    FontFamily {
        value: Vec<String>,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    Rgb {
        r: f64,
        g: f64,
        b: f64,
        alpha: f64,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    Color {
        color_space: String,
        components: (f64, f64, f64),
        alpha: f64,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    #[serde(rename_all = "camelCase")]
    Function {
        name: String,
        args: Box<StyleValue>,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    Image {
        value: ImageSource,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    GuaranteedInvalid {
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    Invalid {
        value: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    Unset {
        value: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    Var {
        value: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        fallback: Option<Box<StyleValue>>,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    Tuple {
        value: Vec<StyleValue>,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    Shadow {
        position: ShadowPosition,
        #[serde(rename = "offsetX")]
        offset_x: Box<StyleValue>,
        #[serde(rename = "offsetY")]
        offset_y: Box<StyleValue>,
        #[serde(skip_serializing_if = "Option::is_none")]
        blur: Option<Box<StyleValue>>,
        #[serde(skip_serializing_if = "Option::is_none")]
        spread: Option<Box<StyleValue>>,
        #[serde(skip_serializing_if = "Option::is_none")]
        color: Option<Box<StyleValue>>,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
    Layers {
        value: Vec<StyleValue>,
        #[serde(skip_serializing_if = "Option::is_none")]
        hidden: Option<bool>,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum ImageSource {
    Asset { value: String },
    Url { url: String },
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum ShadowPosition {
    Inset,
    Outset,
}

pub type CssProperty = String;
pub type CustomProperty = String;
pub type StyleProperty = String;
pub type CssStyleMap = HashMap<CssProperty, StyleValue>;

