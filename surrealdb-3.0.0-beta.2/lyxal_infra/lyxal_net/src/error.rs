use thiserror::Error;

#[derive(Error, Debug)]
pub enum NetError {
    #[error("I/O Error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Serialization Error: {0}")]
    LyxalRevision(#[from] lyxal_revision::Error),

    #[error("Initialization Error: {0}")]
    Init(String),
    #[error("Crypto Error: {0}")]
    CryptoError(String),
    #[error("Configuration Error: {0}")]
    ConfigError(String),
    #[error("Generic Error: {0}")]
    Generic(String),
    #[error("Structure Serialization Error: {0}")]
    Timeout(String),

    #[error("Protocol Error: {0}")]
    Protocol(String),

    #[error("Frame too large: {0} bytes (max {1})")]
    FrameTooLarge(usize, usize),

    #[error("Connection closed by peer")]
    ConnectionClosed,

    #[error("Unexpected Handshake")]
    HandshakeFailed,
}

pub type Result<T> = std::result::Result<T, NetError>;
