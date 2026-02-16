use lazy_static::lazy_static;
use serde_json::Value;

lazy_static! {
    pub static ref ANIMATABLE_PROPERTIES: Value = serde_json::from_str(include_str!("animatable-properties.json")).unwrap();
    pub static ref HTML: Value = serde_json::from_str(include_str!("html.json")).unwrap();
    pub static ref KEYWORD_VALUES: Value = serde_json::from_str(include_str!("keyword-values.json")).unwrap();
    pub static ref PROPERTIES: Value = serde_json::from_str(include_str!("properties.json")).unwrap();
    pub static ref PROPERTY_VALUE_DESCRIPTIONS: Value = serde_json::from_str(include_str!("property-value-descriptions.json")).unwrap();
    pub static ref PSEUDO_CLASSES: Value = serde_json::from_str(include_str!("pseudo-classes.json")).unwrap();
    pub static ref PSEUDO_ELEMENTS: Value = serde_json::from_str(include_str!("pseudo-elements.json")).unwrap();
    pub static ref PSEUDO_SELECTOR_DESCRIPTIONS: Value = serde_json::from_str(include_str!("pseudo-selector-descriptions.json")).unwrap();
    pub static ref SHORTHAND_PROPERTIES: Value = serde_json::from_str(include_str!("shorthand-properties.json")).unwrap();
    pub static ref UNITS: Value = serde_json::from_str(include_str!("units.json")).unwrap();
}
