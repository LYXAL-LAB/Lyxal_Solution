use lyxal_image::{process, ImageContext};
use image::{ImageFormat, DynamicImage, RgbaImage, GenericImageView};

fn create_blank(w: u32, h: u32) -> Vec<u8> {
    let img = DynamicImage::ImageRgba8(RgbaImage::new(w, h));
    let mut bytes = Vec::new();
    img.write_to(&mut std::io::Cursor::new(&mut bytes), ImageFormat::Png).unwrap();
    bytes
}

#[test]
fn test_drop_shadow() {
    let input = create_blank(100, 100);
    // 20x20 rect at 10,10. Shadow offset 10,10.
    // Rect ends at 30,30. Shadow should be around 20,20 to 40,40.
    // Specifically, pixel at 35,35 should be shadow (rect is white #FFFFFF, shadow black #000000)
    let json = r##"{
        "layers": [
            { 
                "type": "shape_rect", 
                "params": { 
                    "x": 10, "y": 10, "width": 20, "height": 20, 
                    "fill": "#FFFFFF"
                },
                "effects": [
                    { "type": "drop_shadow", "offset_x": 10.0, "offset_y": 10.0, "blur": 0.0, "color": "#FF0000", "opacity": 1.0 }
                ]
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).expect("DropShadow failed");
    let img = image::load_from_memory(&res).unwrap();
    
    // Check main rect (white)
    let p_rect = img.get_pixel(15, 15);
    assert_eq!(p_rect, image::Rgba([255, 255, 255, 255]), "Rect should be white");
    
    // Check shadow (red)
    // Offset is +10,+10. Rect is 10,10 to 30,30.
    // Shadow is 20,20 to 40,40.
    // Pixel at 35,35 should be Red.
    let p_shadow = img.get_pixel(35, 35);
    assert_eq!(p_shadow, image::Rgba([255, 0, 0, 255]), "Shadow should be red");
}

#[test]
fn test_outline_outside() {
    let input = create_blank(100, 100);
    // 20x20 rect at 40,40. Outline width 5, Blue.
    let json = r##"{
        "layers": [
            { 
                "type": "shape_rect", 
                "params": { 
                    "x": 40, "y": 40, "width": 20, "height": 20, 
                    "fill": "#FFFFFF"
                },
                "effects": [
                    { "type": "outline", "width": 5.0, "color": "#0000FF", "position": "outside" }
                ]
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).expect("Outline failed");
    let img = image::load_from_memory(&res).unwrap();
    
    // Check rect center (White)
    assert_eq!(img.get_pixel(50, 50), image::Rgba([255, 255, 255, 255]));
    
    // Check outline
    // Rect is 40..60. Outline is 35..40 and 60..65.
    // Left outline at 37, 50.
    let p_out = img.get_pixel(37, 50);
    assert_eq!(p_out, image::Rgba([0, 0, 255, 255]), "Left outline should be blue");
    
    // Check far outside (Transparent) at 30, 50
    assert_eq!(img.get_pixel(30, 50)[3], 0, "Far outside should be transparent");
}

#[test]
fn test_inner_shadow() {
    let input = create_blank(100, 100);
    // 50x50 rect. Inner Shadow offset 5,5 (Red).
    let json = r##"{
        "layers": [
            { 
                "type": "shape_rect", 
                "params": { 
                    "x": 0, "y": 0, "width": 50, "height": 50, 
                    "fill": "#FFFFFF"
                },
                "effects": [
                    { "type": "inner_shadow", "offset_x": 5.0, "offset_y": 5.0, "blur": 0.0, "color": "#FF0000", "opacity": 1.0 }
                ]
            }
        ]
    }"##;
    
    let res = process(&input, json, ImageContext::default()).expect("InnerShadow failed");
    let img = image::load_from_memory(&res).unwrap();
    
    // Top Left (0,0) is part of rect.
    // Inner Shadow Logic: Mask = Inverted Alpha. 
    // Inverted: High outside rect.
    // Offset +5,+5.
    // Means the "Outside Inverted" map shifts Right/Down.
    // So "Top Left" of rect should effectively see the Shifted Outside Mask?
    // Let's trace.
    // Mask: 1 everywhere except 0..50,0..50.
    // Shifted Mask (+5, +5): 1 everywhere except 5..55, 5..55.
    // Original Alpha: 1 inside 0..50.
    // Intersection: (1 inside 0..50) AND (1 everywhere except 5..55).
    // = (0..50) AND NOT (5..55)
    // = (0..50) INTERSECT (0..5 OR 55..inf)
    // = 0..5 region.
    // So the top 5 px and left 5 px stripes should be SHADOWED.
    
    // Pixel 2,2 should be Shadow (Red + White blending?).
    // Implementation uses Over blend.
    // Red over White -> Red.
    
    let p_inner = img.get_pixel(2, 2);
    assert_eq!(p_inner, image::Rgba([255, 0, 0, 255]), "Top-Left inner region should be Red shadow");
    
    // Pixel 25,25 (Middle) should be White (no shadow).
    // Is 25 in 5..55? Yes. So Shifted Mask has 0 there (it's the hole).
    // So no shadow.
    let p_center = img.get_pixel(25, 25);
    assert_eq!(p_center, image::Rgba([255, 255, 255, 255]), "Center should be White");
}

#[test]
fn test_stacking_effects() {
    let input = create_blank(100, 100);
    // Outline Blue then Drop Shadow Red.
    // Outline extends shape. Shadow should respect extended shape.
    // Implementation: List order.
    // Apply Outline -> Layer grows / pixels added.
    // Apply Shadow -> Uses current layer alpha.
    // So shadow should follow outline.
    
    let json = r##"{
        "layers": [
            { 
                "type": "shape_rect", 
                "params": { 
                    "x": 40, "y": 40, "width": 20, "height": 20, 
                    "fill": "#FFFFFF"
                },
                "effects": [
                    { "type": "outline", "width": 5.0, "color": "#0000FF", "position": "outside" },
                    { "type": "drop_shadow", "offset_x": 10.0, "offset_y": 10.0, "blur": 0.0, "color": "#FF0000", "opacity": 1.0 }
                ]
            }
        ]
    }"##;
    
    // Rect: 40..60.
    // Outline: 35..65.
    // Shadow Offset: +10.
    // Shadow of Outline should be at 45..75.
    
    let res = process(&input, json, ImageContext::default()).expect("Stacking failed");
    let img = image::load_from_memory(&res).unwrap();
    
    // Check Outline Pixel at 37, 50 (Blue)
    assert_eq!(img.get_pixel(37, 50), image::Rgba([0, 0, 255, 255]));
    
    // Check Shadow of the Outline Pixel (at 37+10=47, 50+10=60).
    // Pixel 47, 60.
    // 47 is Inside Rect (40..60). So covered by White Rect?
    // Wait. 47,60.
    // Y=60 is edge of Rect (40..60). Outline goes to 65.
    // 60 is covered by Bottom Outline (Blue).
    // So Shadow is covered by Blue Outline.
    // We need to check Shadow where it is exposed.
    
    // Rect 40..60. Outline 35..65.
    // Shadow 45..75. x 45..75.
    // Right side.
    // Outline Right Edge is 65.
    // Shadow Right Edge is 75.
    // Pixel at 70, 50.
    // Should be Shadow (Red).
    let p_shadow_exposed = img.get_pixel(70, 50);
    assert_eq!(p_shadow_exposed, image::Rgba([255, 0, 0, 255]), "Exposed shadow of outline should be red");
}
