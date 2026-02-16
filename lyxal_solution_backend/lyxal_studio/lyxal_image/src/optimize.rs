use regex::Regex;
use serde::{Deserialize, Serialize};
use lazy_static::lazy_static;

pub const IMAGE_SIZES: &[u32] = &[16, 32, 48, 64, 96, 128, 256, 384];
pub const DEVICE_SIZES: &[u32] = &[640, 750, 828, 1080, 1200, 1920, 2048, 3840];

lazy_static! {
    pub static ref ALL_SIZES: Vec<u32> = {
        let mut s = IMAGE_SIZES.to_vec();
        s.extend_from_slice(DEVICE_SIZES);
        s
    };
    static ref VW_RE: Regex = Regex::new(r"(^|\s)(1?\d?\d)vw").unwrap();
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ImageAttributes {
    pub src: String,
    pub src_set: Option<String>,
    pub sizes: Option<String>,
}

pub fn get_widths(width: Option<u32>, sizes: Option<&str>) -> Vec<u32> {
    if let Some(sizes_str) = sizes {
        let mut percent_sizes = Vec::new();
        for cap in VW_RE.captures_iter(sizes_str) {
            if let Ok(val) = cap[2].parse::<u32>() {
                percent_sizes.push(val);
            }
        }

        if !percent_sizes.is_empty() {
            let smallest_ratio = (*percent_sizes.iter().min().unwrap() as f64) * 0.01;
            let min_width = (DEVICE_SIZES[0] as f64 * smallest_ratio) as u32;
            return ALL_SIZES.iter().cloned().filter(|&s| s >= min_width).collect();
        }
        return ALL_SIZES.clone();
    }

    if let Some(w) = width {
        const MAX_DEVICE_PIXEL_RATIO: u32 = 2;
        let limit = w * MAX_DEVICE_PIXEL_RATIO;
        let mut result = Vec::new();
        for &size in ALL_SIZES.iter() {
            result.push(size);
            if size >= limit {
                break;
            }
        }
        return result;
    }

    DEVICE_SIZES.to_vec()
}

pub fn get_image_attributes(
    src: &str,
    width: Option<u32>,
    quality: u32,
    sizes: Option<&str>,
    optimize: bool,
    loader: fn(&str, u32, u32) -> String
) -> ImageAttributes {
    if !optimize {
        return ImageAttributes {
            src: src.to_string(),
            src_set: None,
            sizes: None,
        };
    }

    let widths = get_widths(width, sizes);
    let src_set = widths.iter()
        .map(|&w| format!("{} {}w", loader(src, w, quality), w))
        .collect::<Vec<_>>()
        .join(", ");

    ImageAttributes {
        src: loader(src, *widths.last().unwrap_or(&1080), quality),
        src_set: Some(src_set),
        sizes: Some(sizes.unwrap_or("100vw").to_string()),
    }
}

