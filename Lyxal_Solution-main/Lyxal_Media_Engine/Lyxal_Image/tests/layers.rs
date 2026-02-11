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
fn test_layers_simple_shape_overlay() {
    // Base: White 20x20
    let input = create_solid_image(20, 20, [255, 255, 255, 255]);
    
    // Layer 1: Image (Base copied)
    // Layer 2: Red Rect 10x10 at 0,0
    let json = r##"{
        "layers": [
            { "type": "image" },
            { 
                "type": "shape_rect", 
                "params": { "x": 0, "y": 0, "width": 10, "height": 10, "fill": "#FF0000" },
                "opacity": 1.0,
                "visible": true
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).unwrap();
    
    // Check (0,0) -> Should be Red
    let p = get_pixel_at(&res, 0, 0);
    assert_eq!(p, [255, 0, 0, 255]);
    
    // Check (15,15) -> Should be White (outside rect)
    let p2 = get_pixel_at(&res, 15, 15);
    assert_eq!(p2, [255, 255, 255, 255]);
}

#[test]
fn test_layers_opacity() {
    // Base: Black
    let input = create_solid_image(10, 10, [0, 0, 0, 255]);
    
    // Layer: White Rect, Opacity 0.5 -> Grey (128)
    let json = r##"{
        "layers": [
            { "type": "image" },
            { 
                "type": "shape_rect", 
                "params": { "x": 0, "y": 0, "width": 10, "height": 10, "fill": "#FFFFFF" },
                "opacity": 0.5
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).unwrap();
    let p = get_pixel_at(&res, 0, 0);
    // 255 * 0.5 = 127.5 -> ~128
    assert!(p[0] >= 126 && p[0] <= 129);
}

#[test]
fn test_layers_blend() {
    // Base: White
    let input = create_solid_image(10, 10, [255, 255, 255, 255]);
    
    // Layer: Red, Blend Multiply -> Red
    let json = r##"{
        "layers": [
            { "type": "image" },
            { 
                "type": "shape_rect", 
                "params": { "x": 0, "y": 0, "width": 10, "height": 10, "fill": "#FF0000" },
                "blend": "multiply"
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).unwrap();
    let p = get_pixel_at(&res, 0, 0);
    assert_eq!(p, [255, 0, 0, 255]);
}

#[test]
fn test_layers_invisible() {
    // Base: White
    let input = create_solid_image(10, 10, [255, 255, 255, 255]);
    
    // Layer: Red Rect, invisible -> Should remain White
    let json = r##"{
        "layers": [
            { "type": "image" },
            { 
                "type": "shape_rect", 
                "params": { "x": 0, "y": 0, "width": 10, "height": 10, "fill": "#FF0000" },
                "visible": false
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).unwrap();
    let p = get_pixel_at(&res, 0, 0);
    assert_eq!(p, [255, 255, 255, 255]);
}
