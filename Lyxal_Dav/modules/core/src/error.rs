use thiserror::Error;

#[derive(Error, Debug)]
pub enum DavError {
    #[error("XML Parsing Error")]
    XmlError(#[from] roxmltree::Error),
    
    #[error("Internal Logic Error: {0}")]
    Internal(String),

    #[error("Not Found")]
    NotFound,

    #[error("Forbidden")]
    Forbidden,

    #[error("Method Not Allowed")]
    MethodNotAllowed,

    #[error("Precondition Failed")]
    PreconditionFailed,

    #[error("Not Modified")]
    NotModified,

    #[error("Bad Request: {0}")]
    BadRequest(String),
}
