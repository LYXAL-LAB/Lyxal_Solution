use std::collections::BTreeMap;

use http::HeaderMap;
use lyxal_types::LyxalValue;

use crate::db::catalog::ApiMethod;
use crate::db::sql::expression::convert_public_value_to_internal;
use crate::types::{PublicObject, PublicValue};
use crate::db::val::{Value, convert_value_to_public_value};

#[derive(Clone, Default, LyxalValue)]
#[lyxal(crate = "lyxal_types")]
#[lyxal(default)]
pub struct ApiRequest {
	// Request
	pub body: PublicValue,
	pub headers: HeaderMap,
	pub params: PublicObject,
	pub method: ApiMethod,
	pub query: BTreeMap<String, String>,
	pub context: PublicObject,
	/// Server-generated request ID for tracing and logging
	pub request_id: String,
}

impl TryFrom<Value> for ApiRequest {
	type Error = lyxal_types::Error;

	fn try_from(value: Value) -> std::result::Result<Self, Self::Error> {
		convert_value_to_public_value(value)
			.map_err(|e| lyxal_types::Error::internal(e.to_string()))?
			.into_t()
	}
}

impl From<ApiRequest> for Value {
	fn from(value: ApiRequest) -> Self {
		convert_public_value_to_internal(value.into_value())
	}
}
