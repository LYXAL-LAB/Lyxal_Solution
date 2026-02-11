use image::{DynamicImage, GenericImageView, imageops::FilterType};
use ndarray::{Array4, s};

pub fn preprocess_image(img: &DynamicImage, width: u32, height: u32) -> Array4<f32> {
    let resized = img.resize_exact(width, height, FilterType::Triangle);
    let rgb = resized.to_rgb8();
    
    let mut array = Array4::zeros((1, 3, height as usize, width as usize));
    
    for (x, y, pixel) in rgb.enumerate_pixels() {
        array[[0, 0, y as usize, x as usize]] = (pixel[0] as f32 - 127.5) / 128.0;
        array[[0, 1, y as usize, x as usize]] = (pixel[1] as f32 - 127.5) / 128.0;
        array[[0, 2, y as usize, x as usize]] = (pixel[2] as f32 - 127.5) / 128.0;
    }
    
    array
}

pub fn crop_to_box(img: &DynamicImage, x: f32, y: f32, w: f32, h: f32) -> DynamicImage {
    let (img_w, img_h) = img.dimensions();
    let left = (x * img_w as f32) as u32;
    let top = (y * img_h as f32) as u32;
    let width = (w * img_w as f32) as u32;
    let height = (h * img_h as f32) as u32;
    
    img.crop_imm(left, top, width, height)
}
