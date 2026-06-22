use std::collections::HashMap;
use lyxal_types::asset::Asset;

pub struct AssetPatcher;
impl AssetPatcher {
    pub fn compute_diff(current: &HashMap<String, Asset>, incoming: &HashMap<String, Asset>) -> (Vec<String>, Vec<Asset>) {
        let mut to_delete = Vec::new();
        let mut to_add = Vec::new();
        for id in current.keys() {
            if !incoming.contains_key(id) { to_delete.push(id.clone()); }
        }
        for (id, asset) in incoming {
            if !current.contains_key(id) { to_add.push(asset.clone()); }
        }
        (to_delete, to_add)
    }
}

