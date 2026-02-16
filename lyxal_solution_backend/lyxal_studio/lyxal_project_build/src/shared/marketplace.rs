use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct MarketplaceProduct {
    pub name: String,
    pub author: String,
    pub description: String,
    pub category: String,
    pub thumbnail_asset_id: String,
}

