use lyxal_image::{process, ImageContext, LyxalImage};
use image::{RgbaImage, ImageFormat, DynamicImage, GenericImageView};
use std::sync::{Arc, Mutex};

fn create_blank_image(w: u32, h: u32) -> Vec<u8> {
    let img = DynamicImage::ImageRgba8(RgbaImage::new(w, h));
    let mut bytes = Vec::new();
    img.write_to(&mut std::io::Cursor::new(&mut bytes), ImageFormat::Png).unwrap();
    bytes
}

#[test]
fn test_pipeline_resize_nominal() {
    let input = create_blank_image(100, 100);
    let ctx = ImageContext::default();
    let json = r#"{ "steps": [{ "action": "resize", "w": 50, "h": 50 }] }"#;
    
    let res = process(&input, json, ctx).unwrap();
    let res_img = image::load_from_memory(&res).unwrap();
    assert_eq!(res_img.width(), 50);
    assert_eq!(res_img.height(), 50);
}

#[test]
fn test_pipeline_resize_invalid_zero() {
    let input = create_blank_image(100, 100);
    let ctx = ImageContext::default();
    let json = r#"{ "steps": [{ "action": "resize", "w": 0, "h": 50 }] }"#;
    
    let res = process(&input, json, ctx);
    assert!(res.is_err(), "Should fail on 0 width");
}

#[test]
fn test_pipeline_svg_nominal() {
    let input = create_blank_image(100, 100);
    let ctx = ImageContext::default();
    
    // Simple red rect SVG
    let svg = r#"<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
       <rect width="100" height="100" fill="red" />
    </svg>"#;
    
    // JSON with escaped quotes if needed, or simple string
    // Action: watermark_svg
    // Note: JSON string escaping for "svg" field can be tricky.
    // Using simple approach:
    let json = format!(r#"{{ "steps": [{{ "action": "watermark_svg", "svg": "{}", "x":0, "y":0, "scale":1.0 }}] }}"#, 
        svg.replace("\"", "\\\"").replace("\n", "").replace("\r", ""));

    let res = process(&input, &json, ctx).unwrap();
    let img = image::load_from_memory(&res).unwrap();
    
    // Check pixel at 50,50 is red-ish?
    // Blank image is transparent or black? create_blank_image uses RgbaImage::new -> 0,0,0,0 transparent.
    // SVG rect is red.
    // So pixel should be red (255, 0, 0, 255) approx.
    let px = img.get_pixel(50, 50);
    // Red is 255,0,0. Alpha 255.
    assert!(px[0] > 200, "Should be red");
}

#[test]
fn test_steganography_roundtrip() {
    let input = create_blank_image(200, 200);
    let secret = "Hello World Secret";
    
    // 1. Embed via Pipeline? Non, via API directe pour tester l'extraction
    // Mais on peut utiliser Pipeline pour embed
    let ctx = ImageContext::default();
    let json = format!(r#"{{ "steps": [{{ "action": "embed_secret", "secret": "{}" }}] }}"#, secret);
    
    let processed_bytes = process(&input, &json, ctx).unwrap();
    
    // 2. Load and Extract
    let img = LyxalImage::from_bytes(&processed_bytes, &ImageContext::default()).unwrap();
    let extracted = img.extract_secret().unwrap();
    
    assert_eq!(extracted, secret);
}

#[test]
fn test_pipeline_blur_bounds() {
    let input = create_blank_image(100, 100);
    let ctx = ImageContext::default();
    let json = r#"{ "steps": [{ "action": "blur", "sigma": 200.0 }] }"#; // Trop grand
    
    let res = process(&input, json, ctx);
    assert!(res.is_err(), "Should fail on sigma > 100");
}

/* ML Test Removed: Requires valid ONNX model to init FaceDetector */
