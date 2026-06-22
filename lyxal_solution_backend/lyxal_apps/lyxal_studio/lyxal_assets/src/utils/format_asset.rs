use lyxal_types::asset::Asset;
use serde_json::Value;

pub fn format_asset_row(row: Value) -> Option<Asset> {
    serde_json::from_value(row).ok()
}

