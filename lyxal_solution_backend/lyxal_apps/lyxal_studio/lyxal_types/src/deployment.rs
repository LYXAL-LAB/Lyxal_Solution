use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "kebab-case")]
pub enum DeploymentTemplate {
    Docker,
    Vercel,
    Netlify,
    Ssg,
    SsgNetlify,
    SsgVercel,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "destination", rename_all = "camelCase")]
pub enum Deployment {
    Static {
        name: String,
        assets_domain: String,
        templates: Vec<DeploymentTemplate>,
    },
    #[serde(rename = "saas")]
    Saas {
        domains: Vec<String>,
        assets_domain: Option<String>,
        #[serde(rename = "projectDomain")]
        project_domain: Option<String>,
        exclude_wstd_domain_from_search: Option<bool>,
    },
}

