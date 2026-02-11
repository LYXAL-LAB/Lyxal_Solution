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
fn test_transform_rotate() {
    // Base: 20x20 White
    let input = create_solid_image(20, 20, [255, 255, 255, 255]);
    
    // Layer: Red Rect 20x2, Rotated 90 deg around TOP-LEFT.
    // Position at x=10, y=0.
    // Anchor Top-Left (10, 0).
    // Rotation 90 deg -> Vertical bar at x=10 (growing towards left/negative-x for thickness, and down for length).
    // Rect P(10,0) -> (10,0).
    // Rect P(30,0) -> (10, 20).
    // Rect P(10,2) -> (8, 0).
    // Bounds: x=[8,10], y=[0,20].
    
    let json = r##"{
        "layers": [
            { "type": "image" },
            { 
                "type": "shape_rect", 
                "params": { "x": 10, "y": 0, "width": 20, "height": 2, "fill": "#FF0000" },
                "transform": [
                    { "op": "rotate", "angle": 90.0 }
                ],
                "anchor": "top-left"
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).unwrap();
    
    // (9, 10) should be Red (Inside x=[8,10])
    let p = get_pixel_at(&res, 9, 10);
    assert_eq!(p, [255, 0, 0, 255], "Vertical bar at x=9 expected");
    
    // (15, 0) should be White (Original rect was 10-30, but rotated away)
    let p2 = get_pixel_at(&res, 15, 0);
    assert_eq!(p2, [255, 255, 255, 255], "Unrotated area should be clear");
}

#[test]
fn test_transform_scale_anchor_center() {
    // Base: 20x20 White
    let input = create_solid_image(20, 20, [255, 255, 255, 255]);
    
    // Layer: Blue Rect 10x10 at center (5,5 to 15,15).
    // Center of rect = 10,10.
    // Scale 0.5 around Center (10,10).
    // New Size: 5x5.
    // Position: Center is still 10,10.
    // So bounds: 7.5 to 12.5.
    // Wait, 10x10 scaled 0.5 is 5x5.
    // Top-left was 5,5. 
    // Relative to center (10,10): (-5, -5).
    // Scaled relative: (-2.5, -2.5).
    // New Top-left: 7.5, 7.5.
    // New Bottom-right: 12.5, 12.5.
    
    // So pixel at 10,10 should be Blue.
    // Pixel at 6,6 (inside original but outside scaled) should be White.
    
    let json = r##"{
        "layers": [
            { "type": "image" },
            { 
                "type": "shape_rect", 
                "params": { "x": 5, "y": 5, "width": 10, "height": 10, "fill": "#0000FF" },
                "transform": [
                    { "op": "scale", "kx": 0.5, "ky": 0.5 }
                ],
                "anchor": "center"
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).unwrap();
    
    // Center (10,10) -> Blue
    let p = get_pixel_at(&res, 10, 10);
    assert_eq!(p, [0, 0, 255, 255], "Center should be blue");
    
    // (6,6) -> White
    let p2 = get_pixel_at(&res, 6, 6);
    assert_eq!(p2, [255, 255, 255, 255], "Border (6,6) should be white after scale down");
}

#[test]
fn test_transform_image_layer() {
    // Base: 20x20 White
    let input = create_solid_image(20, 20, [255, 255, 255, 255]);
    
    // Use the input itself as a layer (Red Base)
    let red_base = create_solid_image(20, 20, [255, 0, 0, 255]);
    
    // We can't easily pass a second image in current API for tests without mocking inputs or complex setup.
    // But we can use the main input.
    // Let's use Red Input.
    // Layer 1: Image (Copy of Red Input).
    // Transform: Scale 0.5 around Center.
    // Result: Red square 10x10 in center of transparent buffer? 
    // Wait, Master buffer init logic:
    // If first layer is "image", it copies input.
    // If we want a White Background + Red Image Scaled:
    // Need:
    // Layer 0: Shape Rect White Full (Background) OR Use White Input.
    // Layer 1: Image (which copies input).
    
    // Issue: If Input is White, Layer 1 (Image) is White. Scale 0.5 -> White sq on White bg. Invisible.
    // We need contrast.
    
    // Let's make Input Red.
    // Layer 0: Shape Rect White (BG).
    // Layer 1: Image (Red). Scale 0.5.
    
    let input_red = create_solid_image(20, 20, [255, 0, 0, 255]);
    
    let json = r##"{
        "layers": [
            { "type": "shape_rect", "params": { "x": 0, "y": 0, "width": 20, "height": 20, "fill": "#FFFFFF" } },
            { 
                "type": "image",
                "transform": [
                    { "op": "scale", "kx": 0.5, "ky": 0.5 }
                ],
                "anchor": "center"
            }
        ]
    }"##;
    
    let res = process(&input_red, json, ImageContext::default()).unwrap();
    
    // Center (10,10) -> Red
    let p = get_pixel_at(&res, 10, 10);
    assert_eq!(p, [255, 0, 0, 255], "Center should be red");
    
    // Corner (0,0) -> White
    let p2 = get_pixel_at(&res, 0, 0);
    assert_eq!(p2, [255, 255, 255, 255], "Corner should be white");
}
