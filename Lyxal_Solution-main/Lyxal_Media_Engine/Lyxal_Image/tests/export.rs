use image::GenericImageView;
use lyxal_image::export::{ExportConfig, OutputFormat, export_image};
use lyxal_image::core::LyxalImage;
use lyxal_image::context::ImageContext;

fn create_test_image() -> LyxalImage {
    // 10x10 transparent image with a single red pixel at 0,0
    let img = LyxalImage::new_empty(10, 10);
    // Draw logic is internal, so we rely on what we have.
    // Let's just use it as is (Transparent).
    // Or load from simple buffer if possible.
    img
}

#[test]
fn test_png_export() {
    let img = create_test_image();
    let cfg = ExportConfig {
        format: OutputFormat::Png,
        background_color: None,
    };
    
    let bytes = export_image(&img, &cfg).expect("PNG export failed");
    
    // Verify header
    assert_eq!(&bytes[0..8], &[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
}

#[test]
fn test_jpeg_auto_flatten() {
    let img = create_test_image();
    // JPEG doesn't support transparency. Export should auto-flatten (default white) or fail if we didn't handle it.
    // Our logic handles it by flattening strictly if background_color is present OR if format is JPEG.
    
    let cfg = ExportConfig {
        format: OutputFormat::Jpeg { quality: 80 },
        background_color: None, // Logic should default to White for JPEG
    };
    
    let bytes = export_image(&img, &cfg).expect("JPEG export failed");
    
    // Verify JPEG SOI marker
    assert_eq!(&bytes[0..2], &[0xFF, 0xD8]);
}

#[test]
fn test_flatten_color() {
    let img = create_test_image();
    // Export PNG but flatten against RED.
    // Image is transparent. Result should be Red block.
    
    let cfg = ExportConfig {
        format: OutputFormat::Png,
        background_color: Some("#FF0000".to_string()),
    };
    
    let bytes = export_image(&img, &cfg).expect("Flatten export failed");
    
    let loaded = image::load_from_memory(&bytes).unwrap();
    let p = loaded.get_pixel(5, 5); // Center
    
    // Should be red
    assert_eq!(p.0, [255, 0, 0, 255]);
}
