use thiserror::Error;
use printpdf::Error as PrintPdfError;

#[derive(Error, Debug)]
pub enum PdfRenderError {
    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),

    #[error("Render failure: {0}")]
    RenderFailure(String),
    
    #[error("PDF Library error: {0}")]
    PdfLibError(#[from] PrintPdfError),
}
