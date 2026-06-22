use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone)]
pub enum MarketplaceCategory {
    SectionTemplates,
    PageTemplates,
    IntegrationTemplates,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct MarketplaceProduct {
    pub category: MarketplaceCategory,
    pub name: String,
    pub thumbnail_asset_id: String,
    pub author: String,
    pub description: String,
}

