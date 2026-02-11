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
fn test_mask_clip_alpha() {
    // Canvas 20x20
    let input = create_solid_image(20, 20, [0, 0, 0, 0]); // Transparent base

    // Layer 1: Circle (Source logic for mask). ID="mask_circle".
    // Circle centered at 10,10, radius 5. Red.
    
    // Layer 2: Blue Rect 20x20 covering everything.
    // Mask: "mask_circle" (type: clip/alpha).
    
    // Expected: Blue pixels ONLY inside the circle area.
    
    let json = r##"{
        "layers": [
            { 
                "id": "mask_circle",
                "type": "shape_circle", 
                "params": { "cx": 10, "cy": 10, "radius": 5, "fill": "#FF0000" },
                "visible": false 
            },
            { 
                "type": "shape_rect", 
                "params": { "x": 0, "y": 0, "width": 20, "height": 20, "fill": "#0000FF" },
                "mask": { "type": "alpha", "source": "mask_circle" }
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).unwrap();
    
    // Center (10,10): Inside circle -> Should be Blue (from Rect) * Mask Alpha (255) -> Blue.
    let p_center = get_pixel_at(&res, 10, 10);
    assert_eq!(p_center, [0, 0, 255, 255], "Center should be blue (masked by circle)");
    
    // Corner (0,0): Outside circle -> Mask Alpha 0 -> Transparent.
    let p_corner = get_pixel_at(&res, 0, 0);
    assert_eq!(p_corner[3], 0, "Corner should be transparent");
}

#[test]
fn test_mask_luma() {
    // Canvas 20x20
    let input = create_solid_image(20, 20, [0, 0, 0, 0]);

    // Layer 1: Grey Rect (Source logic for mask). ID="mask_grey". 
    // Fill #808080 (approx 50% luminance).
    
    // Layer 2: White Rect.
    // Mask: "mask_grey" (type: luma).
    
    // Expected: White Rect showing with ~50% opacity.
    
    let json = r##"{
        "layers": [
            { 
                "id": "mask_grey",
                "type": "shape_rect", 
                "params": { "x": 0, "y": 0, "width": 20, "height": 20, "fill": "#808080" },
                "visible": false 
            },
            { 
                "type": "shape_rect", 
                "params": { "x": 0, "y": 0, "width": 20, "height": 20, "fill": "#FFFFFF" },
                "mask": { "type": "luma", "source": "mask_grey" }
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).unwrap();
    
    let p = get_pixel_at(&res, 10, 10);
    // #808080 -> 128. Luma ~ 128. Alpha ~ 128/255 * 255 = 128.
    // Allow slight margin for float calc.
    assert!(p[3] > 120 && p[3] < 135, "Alpha should be approx 128 (50%), got {}", p[3]);
}

#[test]
fn test_mask_source_not_found() {
    let input = create_solid_image(20, 20, [0, 0, 0, 0]);
    
    let json = r##"{
        "layers": [
             { 
                "type": "shape_rect", 
                "params": { "x": 0, "y": 0, "width": 20, "height": 20, "fill": "#0000FF" },
                "mask": { "type": "alpha", "source": "non_existent_id" }
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default());
    assert!(res.is_err(), "Should fail if mask source invalid");
}
