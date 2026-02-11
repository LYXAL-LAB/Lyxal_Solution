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
fn test_effects_nominal() {
    let input = create_test_image(50, 50);
    let ctx = ImageContext::default();
    
    // Test Pixelate + Posterize
    let json = r#"{
        "steps": [
            { "action": "pixelate", "size": 5 },
            { "action": "posterize", "levels": 4 }
        ]
    }"#;
    let res = process(&input, json, ctx).unwrap();
    assert!(!res.is_empty());

    // Test Noise
    let json_noise = r#"{ "steps": [{ "action": "noise", "intensity": 0.5 }] }"#;
    process(&input, json_noise, ImageContext::default()).unwrap();

    // Test Duotone
    let json_duo = r##"{ "steps": [{ "action": "duotone", "color1": "#FF0000", "color2": "#0000FF" }] }"##;
    process(&input, json_duo, ImageContext::default()).unwrap();
    
    // Test Glitch
    let json_glitch = r#"{ "steps": [{ "action": "glitch_horizontal" }, { "action": "glitch_vertical" }] }"#;
    process(&input, json_glitch, ImageContext::default()).unwrap();
}

#[test]
fn test_effects_bounds() {
    let input = create_test_image(10, 10);
    let ctx = ImageContext::default();

    // Invalid Pixelate (< 2)
    let json = r#"{ "steps": [{ "action": "pixelate", "size": 1 }] }"#;
    assert!(process(&input, json, ctx).is_err());
    
    // Invalid Posterize (> 16)
    let json = r#"{ "steps": [{ "action": "posterize", "levels": 20 }] }"#;
    assert!(process(&input, json, ImageContext::default()).is_err());
    
    // Invalid Duotone Hex
    let json = r##"{ "steps": [{ "action": "duotone", "color1": "ZZZZZZ", "color2": "#000000" }] }"##;
    assert!(process(&input, json, ImageContext::default()).is_err());
}
