use lazy_static::lazy_static;
use std::collections::HashMap;

pub mod overrides;
pub mod possible_standard_names;
pub mod elements;
pub mod attributes;
pub mod aria;
pub mod pseudo_classes;

pub use elements::Element;
pub use attributes::Attribute;
pub use aria::AriaAttribute;

lazy_static! {
    pub static ref ARIA_ATTRIBUTES: Vec<AriaAttribute> = aria::get_aria_attributes();
    pub static ref ATTRIBUTES_BY_TAG: HashMap<String, Vec<Attribute>> = attributes::get_attributes_by_tag();
    pub static ref ELEMENTS_BY_TAG: HashMap<String, Element> = elements::get_elements();
    pub static ref PSEUDO_CLASSES_BY_TAG: HashMap<String, Vec<String>> = pseudo_classes::get_pseudo_classes_by_tag();
}

pub fn is_void_element(tag: &str) -> bool {
    overrides::VOID_ELEMENTS.contains(&tag)
}

pub fn is_ignored_tag(tag: &str) -> bool {
    overrides::IGNORED_TAGS.contains(&tag)
}

pub fn get_standard_name(name: &str) -> &str {
    possible_standard_names::POSSIBLE_STANDARD_NAMES.get(name).copied().unwrap_or(name)
}

