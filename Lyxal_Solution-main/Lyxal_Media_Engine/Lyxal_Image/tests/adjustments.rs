use lyxal_image::{process, ImageContext};
use image::{ImageFormat, DynamicImage, RgbaImage};

fn create_test_image(w: u32, h: u32) -> Vec<u8> {
    let img = DynamicImage::ImageRgba8(RgbaImage::from_fn(w, h, |x, y| {
        image::Rgba([(x % 255) as u8, (y % 255) as u8, 100, 255])
    }));
    let mut bytes = Vec::new();
    img.write_to(&mut std::io::Cursor::new(&mut bytes), ImageFormat::Png).unwrap();
    bytes
}

#[test]
fn test_adjustments_nominal() {
    let input = create_test_image(50, 50);
    let ctx = ImageContext::default();
    
    // Brightness + Contrast + Saturation
    let json = r#"{
        "steps": [
            { "action": "brightness", "value": 0.2 },
            { "action": "contrast", "value": 0.1 },
            { "action": "saturation", "value": 1.5 }
        ]
    }"#;
    
    let res = process(&input, json, ctx).unwrap();
    assert!(!res.is_empty());
}

#[test]
fn test_adjustments_bounds() {
    let input = create_test_image(10, 10);
    let ctx = ImageContext::default();

    // Invalid Brightness (> 1.0)
    let json = r#"{ "steps": [{ "action": "brightness", "value": 1.5 }] }"#;
    let res = process(&input, json, ctx);
    assert!(res.is_err());
    
    // Invalid Shadows (< 0.0)
    let json = r#"{ "steps": [{ "action": "shadows", "value": -0.1 }] }"#;
    let res = process(&input, json, ImageContext::default());
    assert!(res.is_err());
}

#[test]
fn test_sepia_vignette() {
    let input = create_test_image(20, 20);
    let ctx = ImageContext::default();
    
    let json = r#"{
        "steps": [
            { "action": "sepia", "value": 0.8 },
            { "action": "vignette", "value": 0.5 }
        ]
    }"#;
    let res = process(&input, json, ctx).unwrap();
    assert!(!res.is_empty());
}

#[test]
fn test_all_bloc1_steps() {
    let input = create_test_image(10, 10);
    let json = r#"{
        "steps": [
            { "action": "brightness", "value": 0.1 },
            { "action": "contrast", "value": 0.1 },
            { "action": "saturation", "value": 0.1 },
            { "action": "temperature", "value": 0.1 },
            { "action": "tint", "value": 0.1 },
            { "action": "shadows", "value": 0.1 },
            { "action": "highlights", "value": 0.1 },
            { "action": "sharpness", "value": 0.5 },
            { "action": "vignette", "value": 0.1 },
            { "action": "sepia", "value": 0.1 }
        ]
    }"#;
     process(&input, json, ImageContext::default()).unwrap();
}
