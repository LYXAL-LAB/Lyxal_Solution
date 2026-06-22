use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum DeploymentDestination { Saas, Static }

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PublishInput {
    pub build_id: String,
    pub builder_origin: String,
    pub destination: DeploymentDestination,
    pub branch_name: String,
    pub log_project_name: String,
}

