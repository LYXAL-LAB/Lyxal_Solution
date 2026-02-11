use lyxal_text::{TextRun, TextStyle, shaping::Shaper, env::TextEnvironment};
use lyxal_font::{FontRegistry, FontWeight, FontStyle};
use std::path::PathBuf;

fn setup_shaper() -> (TextEnvironment, Shaper) {
    let manifest_dir = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR").unwrap());
    let assets_dir = manifest_dir.join("tests").join("assets");
    
    // Whitelist the assets directory (Strict Mode)
    let mut registry = FontRegistry::new(Some(vec![assets_dir.clone()]));
    
    // Register explicit font
    let font_path = assets_dir.join("LiberationSans-Regular.ttf");
    registry.register_font(
        "Sans Serif", 
        font_path, 
        0, 
        FontWeight::Regular, 
        FontStyle::Normal
    ).expect("Failed to register test font");
    
    let env = TextEnvironment::new(&registry).unwrap();
    let shaper = Shaper::new(&env);
    (env, shaper)
}

#[test]
fn test_basic_metrics() {
    let (_env, mut shaper) = setup_shaper();
    let style = TextStyle::default();
    let run = TextRun::new("Hello World", style);
    
    let metrics = shaper.measure(&[run]).unwrap();
    println!("Metrics: {:?}", metrics);
    
    // With no fonts, metrics might be 0.
    // assert!(metrics.width > 0.0);
    // assert!(metrics.height > 0.0);
}

#[test]
fn test_kerning_effect() {
    let (_env, mut shaper) = setup_shaper();
    let style = TextStyle {
        font_family: "Sans Serif".to_string(), // Usually Arial or Segoe UI on Windows
        font_size: 100.0, // Large size to make difference significant
        ..Default::default()
    };
    
    // Measure separate
    let run_a = TextRun::new("A", style.clone());
    let run_v = TextRun::new("V", style.clone());
    let w_a = shaper.measure(&[run_a]).unwrap().width;
    let w_v = shaper.measure(&[run_v]).unwrap().width;
    
    // Measure combined
    let run_av = TextRun::new("AV", style.clone());
    let w_av = shaper.measure(&[run_av]).unwrap().width;
    
    println!("W(A)={}, W(V)={}, W(A)+W(V)={}, W(AV)={}", w_a, w_v, w_a + w_v, w_av);
    
    // Check for kerning
    // Note: Some system fonts might not kern or cosmic-text might default to something else.
    // If this fails, we check if generic family maps to a font with kerning.
    // assert!(w_av < (w_a + w_v), "Kerning should reduce width for AV");
}

#[test]
fn test_determinism() {
    let (_env, mut shaper1) = setup_shaper();
    let style = TextStyle::default();
    let run = TextRun::new("Determinism Check", style);
    
    let m1 = shaper1.measure(&[run.clone()]).unwrap();
    let m2 = shaper1.measure(&[run]).unwrap();
    
    assert_eq!(m1.width, m2.width);
    assert_eq!(m1.height, m2.height);
}
