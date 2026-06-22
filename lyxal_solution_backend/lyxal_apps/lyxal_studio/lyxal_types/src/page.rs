use serde::{Deserialize, Serialize};
use crate::LyxalStudioData;


#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Folder {
    pub id: String,
    pub name: String,
    pub slug: String,
    pub children: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PageMeta {
    pub title: String,
    pub description: Option<String>,
    pub exclude_page_from_search: Option<serde_json::Value>,
    pub language: Option<serde_json::Value>,
    pub social_image_asset_id: Option<String>,
    pub social_image_url: Option<serde_json::Value>,
    pub status: Option<serde_json::Value>,
    pub redirect: Option<serde_json::Value>,
    pub custom: Option<Vec<CustomMeta>>,
    pub document_type: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CustomMeta {
    pub property: String,
    pub content: serde_json::Value,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Page {
    pub id: String,
    pub name: String,
    pub path: String,
    pub root_instance_id: String, // ADDED
    pub meta: PageMeta,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Pages { // ADDED
    pub home_page: Page,
    pub pages: Vec<Page>,
    pub folders: Vec<Folder>,
}

impl Page {
    pub fn is_pathname_pattern(path: &str) -> bool {
        path.contains(':') || path.contains('*')
    }
}

pub fn get_page_path(id: &str, data: &LyxalStudioData) -> String {
    let all_pages: Vec<&Page> = std::iter::once(&data.home_page).chain(data.pages.values()).collect();
    for page in all_pages {
        if page.id == id {
            return page.path.clone();
        }
    }
    String::new()
}



