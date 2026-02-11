use lyxal_image::{process, ImageContext};
use image::{ImageFormat, DynamicImage, RgbaImage, GenericImageView};

fn create_solid_image(w: u32, h: u32, color: [u8; 4]) -> Vec<u8> {
    let img = DynamicImage::ImageRgba8(RgbaImage::from_fn(w, h, |_, _| {
        image::Rgba(color)
    }));
    let mut bytes = Vec::new();
    img.write_to(&mut std::io::Cursor::new(&mut bytes), ImageFormat::Png).unwrap();
    bytes
}

fn get_pixel_at(bytes: &[u8], x: u32, y: u32) -> [u8; 4] {
    let img = image::load_from_memory(bytes).unwrap();
    img.get_pixel(x, y).0
}

#[test]
fn test_blend_multiply() {
    // White background (255, 255, 255) x Red blend (255, 0, 0) -> Should be Red
    let input = create_solid_image(10, 10, [255, 255, 255, 255]);
    let json = r##"{ "steps": [{ "action": "blend", "mode": "multiply", "color": "#FF0000" }] }"##;
    
    let res = process(&input, json, ImageContext::default()).unwrap();
    let p = get_pixel_at(&res, 0, 0);
    assert_eq!(p, [255, 0, 0, 255]);
    
    // Grey (128) x Grey (128) -> ~64
    let input = create_solid_image(10, 10, [128, 128, 128, 255]);
    let json = r##"{ "steps": [{ "action": "blend", "mode": "multiply", "color": "#808080" }] }"##;
    let res = process(&input, json, ImageContext::default()).unwrap();
    let p = get_pixel_at(&res, 0, 0);
    // 0.5 * 0.5 = 0.25 -> ~64
    assert!(p[0] >= 63 && p[0] <= 65);
}

#[test]
fn test_blend_screen() {
    // Black (0) x White (255) -> 255
    let input = create_solid_image(10, 10, [0, 0, 0, 255]);
    let json = r##"{ "steps": [{ "action": "blend", "mode": "screen", "color": "#FFFFFF" }] }"##;
    let res = process(&input, json, ImageContext::default()).unwrap();
    let p = get_pixel_at(&res, 0, 0);
    assert_eq!(p, [255, 255, 255, 255]);
}

#[test]
fn test_blend_difference() {
    // White (255) - Red (255, 0, 0) -> (0, 255, 255) aka Cyan
    let input = create_solid_image(10, 10, [255, 255, 255, 255]);
    let json = r##"{ "steps": [{ "action": "blend", "mode": "difference", "color": "#FF0000" }] }"##;
    let res = process(&input, json, ImageContext::default()).unwrap();
    let p = get_pixel_at(&res, 0, 0);
    assert_eq!(p, [0, 255, 255, 255]);
}

#[test]
fn test_blend_overlay() {
    // Grey (128) base. Overlay Red (255, 0, 0).
    // Overlay logic: If bg > 0.5: 1 - 2(1-bg)(1-fg)
    // Bg=0.5 -> formula discontinuity/neutral usually?
    // Let's test standard darker overlay
    // Bg=100 (0.39) < 0.5 -> 2 * bg * fg
    // Fg=255 (1.0). Result = 2 * 0.39 * 1.0 = 0.78 (199)
    let input = create_solid_image(10, 10, [100, 100, 100, 255]); 
    let json = r##"{ "steps": [{ "action": "blend", "mode": "overlay", "color": "#FFFFFF" }] }"##;
    let res = process(&input, json, ImageContext::default()).unwrap();
    let p = get_pixel_at(&res, 0, 0);
    // 2 * (100/255) * 1.0 * 255 = 200
    assert!(p[0] >= 199 && p[0] <= 201);
}

#[test]
fn test_error_hex() {
    let input = create_solid_image(10, 10, [0, 0, 0, 255]);
    let json = r##"{ "steps": [{ "action": "blend", "mode": "multiply", "color": "BADHEX" }] }"##;
    assert!(process(&input, json, ImageContext::default()).is_err());
}
