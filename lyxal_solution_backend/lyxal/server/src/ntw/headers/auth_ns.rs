use axum_extra::headers;
use axum_extra::headers::Header;
use http::{HeaderName, HeaderValue};
use lyxal::headers::AUTH_NS;

/// Typed header implementation for the `lyxal-auth-ns` header.
/// It's used to specify the namespace to use for the basic authentication.
pub struct LyxalAuthNamespace(HeaderValue, String);

impl Header for LyxalAuthNamespace {
	fn name() -> &'static HeaderName {
		&AUTH_NS
	}

	fn decode<'i, I>(values: &mut I) -> Result<Self, headers::Error>
	where
		I: Iterator<Item = &'i HeaderValue>,
	{
		let value = values.next().ok_or_else(headers::Error::invalid)?.clone();
		let string = value.to_str().map_err(|_| headers::Error::invalid())?.to_string();

		Ok(LyxalAuthNamespace(value, string))
	}

	fn encode<E>(&self, values: &mut E)
	where
		E: Extend<HeaderValue>,
	{
		values.extend(std::iter::once(self.into()));
	}
}

impl std::ops::Deref for LyxalAuthNamespace {
	type Target = String;

	fn deref(&self) -> &Self::Target {
		&self.1
	}
}

impl From<LyxalAuthNamespace> for HeaderValue {
	fn from(value: LyxalAuthNamespace) -> Self {
		HeaderValue::from(&value)
	}
}

impl From<&LyxalAuthNamespace> for HeaderValue {
	fn from(value: &LyxalAuthNamespace) -> Self {
		value.0.clone()
	}
}
