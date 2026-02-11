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
fn test_shapes_nominal() {
    let input = create_test_image(200, 200);
    let ctx = ImageContext::default();
    
    // Rect + Circle
    let json_basic = r##"{
        "steps": [
            { "action": "shape_rect", "x": 10, "y": 10, "width": 50, "height": 50, "fill": "#FF0000", "stroke": "#000000", "stroke_width": 2 },
            { "action": "shape_circle", "cx": 100, "cy": 100, "radius": 30, "fill": "#00FF00" }
        ]
    }"##;
    process(&input, json_basic, ctx.clone()).unwrap();

    // Line + Arrow
    let json_lines = r##"{
        "steps": [
            { "action": "shape_line", "x1": 0, "y1": 0, "x2": 200, "y2": 200, "stroke": "#0000FF", "stroke_width": 5 },
            { "action": "shape_arrow", "x1": 50, "y1": 50, "x2": 150, "y2": 50, "stroke": "#FFFF00", "stroke_width": 3, "head_size": 10 }
        ]
    }"##;
    process(&input, json_lines, ctx.clone()).unwrap();
    
    // Polygon
    let json_poly = r##"{
        "steps": [
            { "action": "shape_polygon", "points": [[10,10], [50,10], [30, 50]], "fill": "#00FFFF", "stroke": "#FFFFFF", "stroke_width": 1 }
        ]
    }"##;
    process(&input, json_poly, ctx).unwrap();
}

#[test]
fn test_shapes_errors() {
    let input = create_test_image(50, 50);
    let ctx = ImageContext::default();

    // Invalid Rect (w=0)
    let json = r##"{ "steps": [{ "action": "shape_rect", "x": 10, "y": 10, "width": 0, "height": 50 }] }"##;
    assert!(process(&input, json, ctx.clone()).is_err());
    
    // Invalid Radius
    let json = r##"{ "steps": [{ "action": "shape_circle", "cx": 10, "cy": 10, "radius": -5 }] }"##;
    assert!(process(&input, json, ctx.clone()).is_err());
    
    // Invalid Hex
    let json = r##"{ "steps": [{ "action": "shape_line", "x1": 0, "y1": 0, "x2": 10, "y2": 10, "stroke": "RED", "stroke_width": 1 }] }"##;
    assert!(process(&input, json, ctx).is_err());
}
