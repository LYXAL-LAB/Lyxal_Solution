use lyxal_types::{prop::Prop, asset::Asset, page::Page};
use std::collections::HashMap;

pub struct PropsNormalizer<'a> {
    pub assets: &'a HashMap<String, Asset>,
    pub pages: &'a HashMap<String, Page>,
    pub asset_base_url: String,
}

impl<'a> PropsNormalizer<'a> {
    pub fn normalize(&self, prop: &Prop) -> Option<(String, String)> {
        match &prop.value {
            lyxal_types::prop::PropValue::Asset(asset_id) => {
                if let Some(asset) = self.assets.get(asset_id) {
                    let url = format!("{}{}", self.asset_base_url, asset.name());
                    return Some((prop.name.clone(), url));
                }
            },
            lyxal_types::prop::PropValue::Page(page_id) => {
                // page_id is &serde_json::Value, need to convert to &str for HashMap key
                let id_str = page_id.as_str().unwrap_or_default();
                if let Some(page) = self.pages.get(id_str) {
                    return Some((prop.name.clone(), page.path.clone()));
                }
            },
            lyxal_types::prop::PropValue::String(s) => return Some((prop.name.clone(), s.clone())),
            lyxal_types::prop::PropValue::Number(n) => return Some((prop.name.clone(), n.to_string())),
            lyxal_types::prop::PropValue::Boolean(b) => return Some((prop.name.clone(), b.to_string())),
            _ => {} 
        }
        None
    }
}

