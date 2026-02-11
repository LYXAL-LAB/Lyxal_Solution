use lyxal_text::{TextRun, TextStyle, shaping::Shaper, PathGeometry, env::TextEnvironment};
use lyxal_font::{FontRegistry, FontWeight, FontStyle};
use std::path::PathBuf;
use std::f32::consts::PI;

fn setup_shaper() -> (TextEnvironment, Shaper) {
    let manifest_dir = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR").unwrap());
    let assets_dir = manifest_dir.join("tests").join("assets");
    
    let mut registry = FontRegistry::new(Some(vec![assets_dir.clone()]));
    
    let font_path = assets_dir.join("LiberationSans-Regular.ttf");
    registry.register_font("Sans Serif", font_path, 0, FontWeight::Regular, FontStyle::Normal)
        .expect("Failed to register test font");
        
    let env = TextEnvironment::new(&registry).unwrap();
    let shaper = Shaper::new(&env);
    (env, shaper)
}

#[test]
fn test_circle_geometry() {
    let geometry = PathGeometry::Circle {
        radius: 100.0,
        center_x: 0.0,
        center_y: 0.0,
        start_angle: 0.0,
        clockwise: true,
    };
    
    // Distance 0 -> Angle 0 -> (100, 0)
    let p0 = geometry.get_point(0.0);
    assert!((p0.x - 100.0).abs() < 0.01);
    assert!((p0.y - 0.0).abs() < 0.01);
    // Rotation: 0 + PI/2 = PI/2 (90 deg, pointing down screen Y)
    assert!((p0.rotation - PI/2.0).abs() < 0.01);
    
    // Distance quarter circle (2*PI*100 / 4) = 50*PI = 157.07
    let p_q = geometry.get_point(50.0 * PI);
    // Angle PI/2 -> (0, 100)
    assert!((p_q.x - 0.0).abs() < 0.01);
    assert!((p_q.y - 100.0).abs() < 0.01);
}

#[test]
fn test_layout_on_circle() {
    let (_env, mut shaper) = setup_shaper();
    let style = TextStyle::default();
    let run = TextRun::new("Circle", style);
    
    let geometry = PathGeometry::Circle {
        radius: 100.0,
        center_x: 100.0,
        center_y: 100.0,
        start_angle: 0.0,
        clockwise: true,
    };
    
    let layout = shaper.layout_text_on_path(&[run], &geometry).unwrap();
    
    assert!(!layout.glyphs.is_empty());
    
    // Check first glyph
    let g0 = &layout.glyphs[0];
    // Should be at distance ~0 (maybe small offset from bearing)
    // start_angle 0 means (200, 100) relative to center(100,100)? No center is at 100,100 -> (200,100).
    // Let's verify X approx 200, Y approx 100.
    println!("G0: x={}, y={}, rot={}", g0.x, g0.y, g0.rotation);
    
    assert!((g0.x - 200.0).abs() < 5.0, "Should start near rightmost point");
}
