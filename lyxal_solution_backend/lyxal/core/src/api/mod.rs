pub mod err;
pub mod invocation;
pub mod middleware;
pub mod path;
pub mod request;
pub mod response;

use http::HeaderName;

/// Header name for Lyxal request ID tracking
pub const X_LYXAL_REQUEST_ID: HeaderName = HeaderName::from_static("x-lyxal-request-id");

pub mod format {
	//! MIME type string constants for use in HTTP headers

	pub const ANY: &str = "*/*";

	pub const JSON: &str = "application/json";
	pub const CBOR: &str = "application/cbor";
	pub const FLATBUFFERS: &str = "application/vnd.lyxal.flatbuffers";
	pub const NATIVE: &str = "application/vnd.lyxal.native";

	pub const PLAIN: &str = "text/plain";
	pub const OCTET_STREAM: &str = "application/octet-stream";
}
