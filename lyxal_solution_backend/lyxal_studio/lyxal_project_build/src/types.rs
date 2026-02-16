use serde::{Deserialize, Serialize};
use lyxal_types::project::LyxalStudioData;
use lyxal_types::page::Pages;
use lyxal_types::style::{Breakpoint, StyleDecl};
use lyxal_types::instance::Instance;
use lyxal_types::prop::Prop;
use lyxal_types::deployment::Deployment;
use crate::shared::marketplace::MarketplaceProduct;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Build {
    pub id: String,
    pub project_id: String,
    pub version: u32,
    pub created_at: String,
    pub updated_at: String,
    pub pages: Pages,
    pub data: LyxalStudioData,
    pub deployment: Option<Deployment>,
    pub marketplace_product: Option<MarketplaceProduct>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CompactBuild {
    pub id: String,
    pub project_id: String,
    pub version: u32,
    pub created_at: String,
    pub updated_at: String,
    pub pages: Pages,
    pub breakpoints: Vec<Breakpoint>,
    pub styles: Vec<StyleDecl>,
    pub props: Vec<Prop>,
    pub instances: Vec<Instance>,
    pub deployment: Option<Deployment>,
    pub marketplace_product: Option<MarketplaceProduct>,
}

