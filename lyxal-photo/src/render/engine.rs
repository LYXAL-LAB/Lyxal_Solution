use image::{DynamicImage, GenericImageView};
use fast_image_resize as fr;
use std::error::Error;
use std::num::NonZeroU32;

pub struct RenderEngine;

impl RenderEngine {
    /// Décode une image depuis des octets
    pub fn decode(bytes: &[u8]) -> Result<DynamicImage, Box<dyn Error>> {
        Ok(image::load_from_memory(bytes)?)
    }

    /// Redimensionne une image de manière performante en gardant le ratio
    pub fn resize(img: &DynamicImage, max_size: u32) -> Result<DynamicImage, Box<dyn Error>> {
        let (width, height) = img.dimensions();
        let (new_width, new_height) = if width > height {
            let ratio = max_size as f32 / width as f32;
            (max_size, (height as f32 * ratio) as u32)
        } else {
            let ratio = max_size as f32 / height as f32;
            ((width as f32 * ratio) as u32, max_size)
        };

        let src_width = NonZeroU32::new(width).ok_or("Invalid width")?;
        let src_height = NonZeroU32::new(height).ok_or("Invalid height")?;
        let src_image = fr::Image::from_vec_u8(
            src_width,
            src_height,
            img.to_rgba8().into_raw(),
            fr::PixelType::U8x4,
        )?;

        let dst_width = NonZeroU32::new(new_width).ok_or("Invalid dst width")?;
        let dst_height = NonZeroU32::new(new_height).ok_or("Invalid dst height")?;
        let mut dst_image = fr::Image::new(dst_width, dst_height, src_image.pixel_type());
        
        let mut resizer = fr::Resizer::new(fr::ResizeAlg::Convolution(fr::FilterType::Lanczos3));
        resizer.resize(&src_image.view(), &mut dst_image.view())?;

        let dst_buffer = dst_image.into_vec();
        Ok(DynamicImage::ImageRgba8(image::RgbaImage::from_raw(new_width, new_height, dst_buffer).ok_or("Failed to create RgbaImage")?))
    }

    /// Encode en WebP
    pub fn encode_webp(img: &DynamicImage, quality: f32) -> Result<Vec<u8>, Box<dyn Error>> {
        let (w, h) = img.dimensions();
        let encoder = webp::Encoder::from_rgba(img.to_rgba8().as_raw(), w, h);
        let webp_data = encoder.encode(quality);
        Ok(webp_data.to_vec())
    }

    /// Encode en AVIF (via ravif)
    pub fn encode_avif(img: &DynamicImage, quality: f32) -> Result<Vec<u8>, Box<dyn Error>> {
        let (w, h) = img.dimensions();
        let rgba = img.to_rgba8();
        let config = ravif::Config {
            quality,
            speed: 4,
            threads: 0,
            color_space: ravif::ColorSpace::RGB,
            alpha_color_mode: ravif::AlphaColorMode::UnassociatedClean,
        };
        let (avif_data, _) = ravif::encode_rgba(
            ravif::Img::new(rgba.as_raw(), w as usize, h as usize),
            &config,
        ).map_err(|e| format!("AVIF encoding failed: {}", e))?;
        Ok(avif_data)
    }
}
