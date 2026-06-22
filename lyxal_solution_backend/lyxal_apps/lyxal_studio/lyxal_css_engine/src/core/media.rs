use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub struct MediaRuleOptions {
    pub min_width: Option<i32>,
    pub max_width: Option<i32>,
    pub condition: Option<String>,
    pub media_type: Option<String>,
}

pub fn is_simulated_condition(options: &MediaRuleOptions) -> bool {
    options.media_type.is_some() &&
    options.condition.is_none() &&
    options.min_width.is_none() &&
    options.max_width.is_none()
}

pub fn is_condition(options: &MediaRuleOptions) -> bool {
    options.condition.is_some() || is_simulated_condition(options)
}

pub fn compare_media(a: &MediaRuleOptions, b: &MediaRuleOptions) -> std::cmp::Ordering {
    let a_is_cond = is_condition(a);
    let b_is_cond = is_condition(b);

    if a_is_cond && b_is_cond {
        return a.condition.as_deref().unwrap_or("").cmp(b.condition.as_deref().unwrap_or(""));
    }

    if a_is_cond {
        if a.min_width.is_none() && a.max_width.is_none() {
            return std::cmp::Ordering::Greater;
        }
        return std::cmp::Ordering::Less;
    }
    if b_is_cond {
        if b.min_width.is_none() && b.max_width.is_none() {
            return std::cmp::Ordering::Less;
        }
        return std::cmp::Ordering::Greater;
    }

    if a.min_width.is_none() && a.max_width.is_none() {
        return std::cmp::Ordering::Less;
    }
    if b.min_width.is_none() && b.max_width.is_none() {
        return std::cmp::Ordering::Greater;
    }

    if let (Some(am), Some(bm)) = (a.min_width, b.min_width) {
        return am.cmp(&bm);
    }
    if let (Some(am), Some(bm)) = (a.max_width, b.max_width) {
        return bm.cmp(&am);
    }

    if a.min_width.is_some() { std::cmp::Ordering::Greater } else { std::cmp::Ordering::Less }
}

pub fn match_media(options: &MediaRuleOptions, width: i32) -> bool {
    let min = options.min_width.unwrap_or(i32::MIN);
    let max = options.max_width.unwrap_or(i32::MAX);
    width >= min && width <= max
}

pub fn find_applicable_media(media: &[MediaRuleOptions], width: i32) -> Option<MediaRuleOptions> {
    let mut sorted = media.to_vec();
    sorted.sort_by(compare_media);
    sorted.reverse();

    for options in sorted {
        if match_media(&options, width) {
            return Some(options);
        }
    }
    None
}

