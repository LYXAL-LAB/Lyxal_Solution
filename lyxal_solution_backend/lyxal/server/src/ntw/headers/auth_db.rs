use axum_extra::headers;
use axum_extra::headers::Header;
use http::{HeaderName, HeaderValue};
use lyxal::headers::AUTH_DB;

/// Typed header implementation for the `lyxal-auth-db` header.
/// It's used to specify the database to use for the basic authentication.
pub struct LyxalAuthDatabase(HeaderValue, String);

impl Header for LyxalAuthDatabase {
	fn name() -> &'static HeaderName {
		&AUTH_DB
	}

	fn decode<'i, I>(values: &mut I) -> Result<Self, headers::Error>
	where
		I: Iterator<Item = &'i HeaderValue>,
	{
		let value = values.next().ok_or_else(headers::Error::invalid)?.clone();
		let string = value.to_str().map_err(|_| headers::Error::invalid())?.to_string();

		Ok(LyxalAuthDatabase(value, string))
	}

	fn encode<E>(&self, values: &mut E)
	where
		E: Extend<HeaderValue>,
	{
		values.extend(std::iter::once(self.into()));
	}
}

impl std::ops::Deref for LyxalAuthDatabase {
	type Target = String;

	fn deref(&self) -> &Self::Target {
		&self.1
	}
}

impl From<LyxalAuthDatabase> for HeaderValue {
	fn from(value: LyxalAuthDatabase) -> Self {
		HeaderValue::from(&value)
	}
}

impl From<&LyxalAuthDatabase> for HeaderValue {
	fn from(value: &LyxalAuthDatabase) -> Self {
		value.0.clone()
	}
}
