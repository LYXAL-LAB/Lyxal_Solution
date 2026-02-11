use std::collections::HashMap;

#[derive(Debug, Clone, PartialEq)]
pub struct VCard {
    pub properties: Vec<Property>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct Property {
    pub group: Option<String>,
    pub name: String,
    pub params: HashMap<String, Vec<String>>,
    pub value: String,
}

impl VCard {
    pub fn new() -> Self {
        Self { properties: Vec::new() }
    }

    pub fn get_property(&self, name: &str) -> Option<&Property> {
        self.properties.iter().find(|p| p.name.eq_ignore_ascii_case(name))
    }
    
    pub fn get_properties(&self, name: &str) -> Vec<&Property> {
        self.properties.iter().filter(|p| p.name.eq_ignore_ascii_case(name)).collect()
    }
}

