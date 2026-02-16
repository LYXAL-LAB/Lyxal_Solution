use crate::schema::CssStyleMap;

pub fn prefix_styles(style_map: &CssStyleMap) -> CssStyleMap {
    let mut new_map = CssStyleMap::new();
    for (property, value) in style_map {
        if property == "background-clip" {
            new_map.insert("-webkit-background-clip".to_string(), value.clone());
        }
        if property == "user-select" {
            new_map.insert("-webkit-user-select".to_string(), value.clone());
        }
        if property == "text-size-adjust" {
            new_map.insert("-webkit-text-size-adjust".to_string(), value.clone());
        }
        if property == "backdrop-filter" {
            new_map.insert("-webkit-backdrop-filter".to_string(), value.clone());
        }
        if property == "view-timeline-name" || property == "scroll-timeline-name" || property == "view-timeline-inset" {
            new_map.insert(format!("--{}", property), value.clone());
        }
        new_map.insert(property.clone(), value.clone());
    }
    new_map
}

