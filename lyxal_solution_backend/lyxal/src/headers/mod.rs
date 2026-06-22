//! HTTP headers used by Lyxal

use reqwest::header::HeaderName;

pub static ID: HeaderName = HeaderName::from_static("lyxal-id");
pub static NS: HeaderName = HeaderName::from_static("lyxal-ns");
pub static DB: HeaderName = HeaderName::from_static("lyxal-db");
pub static AUTH_NS: HeaderName = HeaderName::from_static("lyxal-auth-ns");
pub static AUTH_DB: HeaderName = HeaderName::from_static("lyxal-auth-db");
pub static VERSION: HeaderName = HeaderName::from_static("lyxal-version");
