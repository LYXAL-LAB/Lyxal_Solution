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
fn test_text_basic_draw() {
    let input = create_blank(200, 100);
    
    // Draw "Hello" in Red centered.
    let json = r##"{
        "layers": [
            { 
                "type": "text", 
                "params": { 
                    "text": "Hello",
                    "box": { "width": 200, "height": 100 },
                    "align": { "h": "center", "v": "middle" }, 
                    "font": { "size": 30 },
                    "fill": "#FF0000"
                }
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default());
    assert!(res.is_ok());
    let res_bytes = res.unwrap();
    
    // Check center pixel - should be red (roughly, depending on font shape "H" or "e" etc.)
    // Hello is short, so center of 200x100 should hit text.
    // 30px font.
    let p = get_pixel_at(&res_bytes, 100, 50);
    // Might hit a gap between letters?
    // "Hello" ~ 80px wide?
    // Let's check a few pixels to be safe or assert non-empty.
    
    // Assert image is NOT transparent everywhere
    let img = image::load_from_memory(&res_bytes).unwrap();
    let mut has_red = false;
    for pixel in img.pixels() {
        if pixel.2 == image::Rgba([255, 0, 0, 255]) {
            has_red = true;
            break;
        }
    }
    assert!(has_red, "Text should draw red pixels");
}

#[test]
fn test_text_wrap() {
    let input = create_blank(100, 200);
    
    // Narrow box, Long text -> Should Wrap.
    // Text: "A A A A" with spaces.
    let json = r##"{
        "layers": [
            { 
                "type": "text", 
                "params": { 
                    "text": "WWWW WWWW",
                    "box": { "width": 50, "height": 200 }, 
                    "font": { "size": 30 },
                    "fill": "#00FF00"
                }
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).unwrap();
    
    // With width 50 and size 30, "WWWW" (approx 4*30=120px) won't fit on one line.
    // Should wrap.
    // Vertical extent should be > 30px.
    
    let img = image::load_from_memory(&res).unwrap();
    // Check pixel at y=50 (second line area approx)
    let mut has_green_lower = false;
    for y in 40..80 {
        for x in 0..50 {
            if img.get_pixel(x, y).0 == [0, 255, 0, 255] {
                has_green_lower = true;
                break;
            }
        }
    }
    assert!(has_green_lower, "Text should wrap to second line");
}

#[test]
fn test_text_transform() {
     let input = create_blank(100, 100);
    
    // Rotate 90 degrees. vertical text.
    let json = r##"{
        "layers": [
            { 
                "type": "text", 
                "params": { 
                    "text": "---", 
                    "box": { "width": 100, "height": 100 },
                    "font": { "size": 20 },
                    "fill": "#0000FF"
                },
                "transform": [ { "op": "rotate", "angle": 90 } ],
                "anchor": "center"
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).unwrap();
    // Validate? Complex. Just ensure no panic and something draws.
     let img = image::load_from_memory(&res).unwrap();
     let mut has_blue = false;
    for pixel in img.pixels() {
        if pixel.2 == image::Rgba([0, 0, 255, 255]) {
            has_blue = true;
            break;
        }
    }
    assert!(has_blue, "Text should draw with transform");
}
