use crate::core::LyxalImage;
use crate::error::LyxalResult;
use fast_image_resize as fr;
use image::DynamicImage; // Removed GenericImageView
use std::num::NonZeroU32;

impl LyxalImage {
    pub fn resize(&mut self, width: u32, height: u32) -> LyxalResult<()> {
        self.with_inner(|img| {
            let src_width = NonZeroU32::new(img.width())
                .ok_or(crate::error::LyxalError::Dimension("Width is 0".into()))?;
            let src_height = NonZeroU32::new(img.height())
                .ok_or(crate::error::LyxalError::Dimension("Height is 0".into()))?;
            let dst_width = NonZeroU32::new(width)
                .ok_or(crate::error::LyxalError::Dimension("Target Width 0".into()))?;
            let dst_height = NonZeroU32::new(height)
                .ok_or(crate::error::LyxalError::Dimension("Target Height 0".into()))?;

            let src_image = fr::Image::from_vec_u8(
                src_width,
                src_height,
                img.to_rgba8().into_raw(),
                fr::PixelType::U8x4,
            ).map_err(|_| crate::error::LyxalError::Encode("Resize buffer error".into()))?;

            let mut dst_image = fr::Image::new(dst_width, dst_height, src_image.pixel_type());
            let mut resizer = fr::Resizer::new(fr::ResizeAlg::Convolution(fr::FilterType::Lanczos3));

            resizer.resize(&src_image.view(), &mut dst_image.view_mut())
                .map_err(|_| crate::error::LyxalError::Encode("Resize failed".into()))?;

            *img = DynamicImage::ImageRgba8(
                image::RgbaImage::from_raw(width, height, dst_image.into_vec())
                    .ok_or(crate::error::LyxalError::InternalError("Failed to create residual buffer".into()))?
            );
            Ok(())
        })
    }

    pub fn crop(&mut self, x: u32, y: u32, w: u32, h: u32) -> LyxalResult<()> {
        self.with_inner(|img| {
            *img = img.crop_imm(x, y, w, h);
            Ok(())
        })
    }
}