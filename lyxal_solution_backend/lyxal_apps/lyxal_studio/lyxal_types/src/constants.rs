pub const ROOT_FOLDER_ID: &str = "root";
pub const ROOT_COMPONENT: &str = "ws:root";
pub const ELEMENT_COMPONENT: &str = "ws:element";
pub const PORTAL_COMPONENT: &str = "Slot";
pub const COLLECTION_COMPONENT: &str = "ws:collection";
pub const DESCENDANT_COMPONENT: &str = "ws:descendant";
pub const BLOCK_COMPONENT: &str = "ws:block";
pub const BLOCK_TEMPLATE_COMPONENT: &str = "ws:block-template";

pub fn is_core_component(component: &str) -> bool {
    match component {
        ROOT_COMPONENT | ELEMENT_COMPONENT | COLLECTION_COMPONENT | 
        DESCENDANT_COMPONENT | BLOCK_COMPONENT | BLOCK_TEMPLATE_COMPONENT => true,
        _ => false,
    }
}

