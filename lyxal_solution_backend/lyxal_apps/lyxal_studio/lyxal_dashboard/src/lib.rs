use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct DomainVirtual {
    pub domain: String,
    pub status: String,
    pub verified: bool,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct DashboardProject {
    pub id: String,
    pub title: String,
    pub domain: String,
    pub created_at: String,
    pub domains_virtual: Vec<DomainVirtual>,
    pub preview_image_asset: Option<serde_json::Value>,
}

impl DashboardProject {
    pub fn map_verified_status(_domain: &str, txt_record: &str, project_txt: &str) -> bool {
        txt_record == project_txt
    }
}


