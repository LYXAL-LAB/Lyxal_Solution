use serde::{Deserialize, Serialize};
use lyxal_types::project::LyxalStudioData;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct ProjectBuild {
    pub id: String,
    pub project_id: String,
    pub data: LyxalStudioData,
    pub version: u32,
    pub created_at: String,
}

