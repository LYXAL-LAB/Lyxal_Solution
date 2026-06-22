use axum_extra::headers;
use axum_extra::headers::Header;
use http::{HeaderName, HeaderValue};
use lyxal::headers::DB;

/// Typed header implementation for the database header.
/// It's used to specify the database to use for database operations.
pub struct LyxalDatabase(HeaderValue, String);

impl Header for LyxalDatabase {
	fn name() -> &'static HeaderName {
		&DB
	}

	fn decode<'i, I>(values: &mut I) -> Result<Self, headers::Error>
	where
		I: Iterator<Item = &'i HeaderValue>,
	{
		let value = values.next().ok_or_else(headers::Error::invalid)?.clone();
		let string = value.to_str().map_err(|_| headers::Error::invalid())?.to_string();

		Ok(LyxalDatabase(value, string))
	}

	fn encode<E>(&self, values: &mut E)
	where
		E: Extend<HeaderValue>,
	{
		values.extend(std::iter::once(self.into()));
	}
}

impl std::ops::Deref for LyxalDatabase {
	type Target = String;

	fn deref(&self) -> &Self::Target {
		&self.1
	}
}

impl From<LyxalDatabase> for HeaderValue {
	fn from(value: LyxalDatabase) -> Self {
		HeaderValue::from(&value)
	}
}

impl From<&LyxalDatabase> for HeaderValue {
	fn from(value: &LyxalDatabase) -> Self {
		value.0.clone()
	}
}
