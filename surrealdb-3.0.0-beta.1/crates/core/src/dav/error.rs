//! DAV Error Types
//!
//! Error definitions for WebDAV/CalDAV/CardDAV operations.

use thiserror::Error;

/// DAV-specific errors
#[derive(Error, Debug)]
pub enum DavError {
    #[error("XML Parsing Error: {0}")]
    XmlError(String),

    #[error("Internal Logic Error: {0}")]
    Internal(String),

    #[error("Not Found")]
    NotFound,

    #[error("Forbidden")]
    Forbidden,

    #[error("Unauthorized")]
    Unauthorized,

    #[error("Method Not Allowed")]
    MethodNotAllowed,

    #[error("Precondition Failed")]
    PreconditionFailed,

    #[error("Not Modified")]
    NotModified,

    #[error("Bad Request: {0}")]
    BadRequest(String),

    #[error("Locked")]
    Locked,

    #[error("Conflict")]
    Conflict,

    #[error("Payload Too Large")]
    PayloadTooLarge,

    #[error("Storage Error: {0}")]
    Storage(String),
}

impl From<roxmltree::Error> for DavError {
    fn from(e: roxmltree::Error) -> Self {
        DavError::XmlError(e.to_string())
    }
}

impl DavError {
    /// Convert to HTTP status code
    pub fn status_code(&self) -> u16 {
        match self {
            DavError::NotFound => 404,
            DavError::Forbidden => 403,
            DavError::Unauthorized => 401,
            DavError::MethodNotAllowed => 405,
            DavError::PreconditionFailed => 412,
            DavError::NotModified => 304,
            DavError::BadRequest(_) => 400,
            DavError::Locked => 423,
            DavError::Conflict => 409,
            DavError::PayloadTooLarge => 413,
            DavError::XmlError(_) | DavError::Internal(_) | DavError::Storage(_) => 500,
        }
    }
}
