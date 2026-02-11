use lyxal_image::{process, ImageContext};
use image::{ImageFormat, DynamicImage, RgbaImage, GenericImageView};

fn create_blank(w: u32, h: u32) -> Vec<u8> {
    let img = DynamicImage::ImageRgba8(RgbaImage::new(w, h));
    let mut bytes = Vec::new();
    img.write_to(&mut std::io::Cursor::new(&mut bytes), ImageFormat::Png).unwrap();
    bytes
}

fn get_pixel_at(bytes: &[u8], x: u32, y: u32) -> [u8; 4] {
    let img = image::load_from_memory(bytes).unwrap();
    img.get_pixel(x, y).0
}

#[test]
fn test_gradient_linear_rect() {
    let input = create_blank(100, 100);
    
    // Rect 100x100. Linear Gradient Left (Red) to Right (Blue).
    let json = r##"{
        "layers": [
            { 
                "type": "shape_rect", 
                "params": { 
                    "x": 0, "y": 0, "width": 100, "height": 100, 
                    "fill": {
                        "type": "linear_gradient",
                        "start": [0.0, 0.0],
                        "end": [1.0, 0.0],
                        "stops": [
                            { "offset": 0.0, "color": "#FF0000" },
                            { "offset": 1.0, "color": "#0000FF" }
                        ]
                    }
                }
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).expect("Gradient rect failed");
    
    // Check Left (Red)
    let p_left = get_pixel_at(&res, 5, 50);
    assert!(p_left[0] > 200, "Left should be reddish");
    assert!(p_left[2] < 50, "Left should not be blue");

    // Check Right (Blue)
    let p_right = get_pixel_at(&res, 95, 50);
    assert!(p_right[2] > 200, "Right should be bluish");
    assert!(p_right[0] < 50, "Right should not be red");
    
    // Check Middle (Purple-ish)
    let p_mid = get_pixel_at(&res, 50, 50);
    assert!(p_mid[0] > 100 && p_mid[0] < 150, "Middle Red ok");
    assert!(p_mid[2] > 100 && p_mid[2] < 150, "Middle Blue ok");
}

#[test]
fn test_gradient_radial_circle() {
    let input = create_blank(100, 100);
    
    // Circle at 50,50 radius 40. Radial Center (Green) to Edge (Black).
    let json = r##"{
        "layers": [
            { 
                "type": "shape_circle", 
                "params": { 
                    "cx": 50, "cy": 50, "radius": 40,
                    "fill": {
                        "type": "radial_gradient",
                        "center": [0.5, 0.5],
                        "radius": 0.5,
                        "stops": [
                            { "offset": 0.0, "color": "#00FF00" },
                            { "offset": 1.0, "color": "#000000" }
                        ]
                    }
                }
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).expect("Radial circle failed");
    
    // Center: Green
    let p_center = get_pixel_at(&res, 50, 50);
    assert!(p_center[1] > 200, "Center should be green");
    
    // Edge (inside circle but near boundary): Darker
    let p_edge = get_pixel_at(&res, 75, 50); // r=25 from center (normalized ~0.625)
    // Should be darker green.
    assert!(p_edge[1] < 200 && p_edge[1] > 50, "Edge should be darker green");
}

#[test]
fn test_gradient_text() {
    let input = create_blank(200, 100);
    
    // Use a full block char to ensure coverage
    let json = r##"{
        "layers": [
            { 
                "type": "text", 
                "params": { 
                    "text": "████",
                    "box": { "width": 100, "height": 100 },
                    "font": { "size": 60 },
                    "fill": {
                        "type": "linear_gradient",
                        "start": [0.0, 0.0],
                        "end": [0.0, 1.0],
                        "stops": [
                            { "offset": 0.0, "color": "#FFFF00" },
                            { "offset": 1.0, "color": "#FF0000" }
                        ]
                    }
                }
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).expect("Gradient text failed");
    
    let img = image::load_from_memory(&res).unwrap();
    
    // Check Center (approx y=50). Expect Orange (Red + Green mixed).
    // Gradient is vertical.
    // Top = Yellow (R=High, G=High).
    // Bottom = Red (R=High, G=Low).
    // Middle = Orange (R=High, G=Medium).
    
    // We search for a non-transparent pixel in the middle area
    let mut found_color = false;
    for y in 40..60 {
        for x in 20..80 {
            let p = img.get_pixel(x, y);
            if p[3] > 100 {
                // Check color
                // R should be high (> 200)
                // G should be medium (around 128? say > 50 and < 200)
                if p[0] > 200 && p[1] > 50 && p[1] < 220 {
                    found_color = true;
                }
            }
        }
    }
    
    assert!(found_color, "Found orange pixel in middle of text gradient");
}
