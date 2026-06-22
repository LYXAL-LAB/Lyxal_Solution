use image::GenericImageView;

pub struct ImageMetadata {
    pub width: u32,
    pub height: u32,
    pub format: String,
}

pub fn get_image_metadata(data: &[u8]) -> Result<ImageMetadata, String> {
    let img = image::load_from_memory(data).map_err(|e| e.to_string())?;
    let (width, height) = img.dimensions();
    
    Ok(ImageMetadata {
        width,
        height,
        format: "unknown".to_string(),
    })
}

