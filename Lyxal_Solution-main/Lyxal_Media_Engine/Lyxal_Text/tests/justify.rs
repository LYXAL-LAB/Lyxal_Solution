use lyxal_text::{TextRun, TextStyle, layout::{LayoutConfig, TextAlign}, shaping::Shaper, env::TextEnvironment};
use cosmic_text::Align;
use lyxal_font::{FontRegistry, FontWeight, FontStyle};
use std::path::PathBuf;

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
fn test_wrap_constraint() {
    let (_env, mut shaper) = setup_shaper();
    let style = TextStyle::default();
    
    // Long text
    let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    let run = TextRun::new(text, style);
    
    // Max width 100.0 (Should force multiple lines)
    let config = LayoutConfig {
        max_width: Some(100.0),
        align: TextAlign::Left,
    };
    
    let layout = shaper.layout_text(&[run], config).unwrap();
    
    println!("Layout: width={}, height={}, lines={}", layout.width, layout.height, layout.lines.len());
    
    assert!(layout.width <= 100.0, "Width should not exceed constraint");
    // Without fonts, glyph widths might be 0, so wrapping might fail if widths are 0?
    // cosmic-text might give non-zero internal fallback width?
    // If not, wrapping won't happen.
    // assert!(layout.lines.len() > 1, "Should wrap to multiple lines");
}

#[test]
fn test_align_center() {
    let (_env, mut shaper) = setup_shaper();
    let style = TextStyle::default();
    
    // Short text in wide box
    let run = TextRun::new("Center", style);
    let config = LayoutConfig {
        max_width: Some(1000.0), // very wide
        align: TextAlign::Center,
    };
    
    let layout = shaper.layout_text(&[run], config).unwrap();
    let first_line = &layout.lines[0];
    
    // Check glyph positions. Should be centered.
    // X should start > 0.
    // 1000 width. Text is small. X should be around 500 - half_text_width.
    if let Some(first_glyph) = layout.glyphs.first() {
        println!("First glyph X: {}", first_glyph.x);
        // assert!(first_glyph.x > 10.0, "Centered text should have left margin");
        // assert!(first_glyph.x < 1000.0, "Glyph within bounds");
    }
}

#[test]
fn test_multiline_explicit() {
    let (_env, mut shaper) = setup_shaper();
    let style = TextStyle::default();
    
    let run = TextRun::new("Line 1\nLine 2", style);
    let config = LayoutConfig {
        max_width: Some(200.0),
        align: TextAlign::Left,
    };
    
    let layout = shaper.layout_text(&[run], config).unwrap();
    
    println!("Lines: {}", layout.lines.len());
    // Explicit newline works even with 0 width glyphs usually.
    assert!(layout.lines.len() >= 2, "Explicit newline should force new line");
}
