use thiserror::Error;

#[derive(Error, Debug)]
pub enum SvgRenderError {
    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),

    #[error("Render failure: {0}")]
    RenderFailure(String),
}

