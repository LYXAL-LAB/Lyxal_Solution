use axum_extra::headers;
use axum_extra::headers::Header;
use http::{HeaderName, HeaderValue};
use lyxal::headers::ID;

/// Typed header implementation for the id header.
/// It's used to specify the session id.
pub struct LyxalId(HeaderValue, String);

impl Header for LyxalId {
	fn name() -> &'static HeaderName {
		&ID
	}

	fn decode<'i, I>(values: &mut I) -> Result<Self, headers::Error>
	where
		I: Iterator<Item = &'i HeaderValue>,
	{
		let value = values.next().ok_or_else(headers::Error::invalid)?.clone();
		let string = value.to_str().map_err(|_| headers::Error::invalid())?.to_string();

		Ok(LyxalId(value, string))
	}

	fn encode<E>(&self, values: &mut E)
	where
		E: Extend<HeaderValue>,
	{
		values.extend(std::iter::once(self.into()));
	}
}

impl std::ops::Deref for LyxalId {
	type Target = String;

	fn deref(&self) -> &Self::Target {
		&self.1
	}
}

impl From<LyxalId> for HeaderValue {
	fn from(value: LyxalId) -> Self {
		HeaderValue::from(&value)
	}
}

impl From<&LyxalId> for HeaderValue {
	fn from(value: &LyxalId) -> Self {
		value.0.clone()
	}
}
