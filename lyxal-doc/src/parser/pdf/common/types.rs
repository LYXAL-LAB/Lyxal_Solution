//! Common PDF types used by both reader and writer

/// Bounding Box for PDF elements
#[derive(Debug, Clone, PartialEq)]
pub struct PdfBBox {
    pub min_x: f32,
    pub min_y: f32,
    pub max_x: f32,
    pub max_y: f32,
}

impl PdfBBox {
    pub fn width(&self) -> f32 {
        self.max_x - self.min_x
    }

    pub fn height(&self) -> f32 {
        self.max_y - self.min_y
    }
}

/// RGBA color representation
#[derive(Debug, Clone, PartialEq)]
pub struct PdfRgba {
    pub r: f32,
    pub g: f32,
    pub b: f32,
    pub a: f32,
}

impl Default for PdfRgba {
    fn default() -> Self {
        Self { r: 0.0, g: 0.0, b: 0.0, a: 1.0 }
    }
}

/// PDF Color Space
#[derive(Debug, Clone, PartialEq)]
pub enum PdfColorSpace {
    DeviceRGB,
    DeviceGray,
    DeviceCMYK,
    Lab,
    ICCBased { n: u8 },
    Other(String),
}
