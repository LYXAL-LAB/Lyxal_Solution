use std::ops::Deref;

use lyxal_revision::revisioned;
use storekey::{BorrowDecode, Encode};
use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_db::val::IndexFormat;

#[revisioned(revision = 1)]
#[derive(Clone, Debug, Default, Eq, PartialEq, PartialOrd, Hash, Encode, BorrowDecode)]
#[storekey(format = "()")]
#[storekey(format = "IndexFormat")]
#[repr(transparent)]
pub struct Bytes(pub(crate) ::bytes::Bytes);

impl Bytes {
	pub fn into_inner(self) -> bytes::Bytes {
		self.0
	}
}

impl From<Vec<u8>> for Bytes {
	fn from(v: Vec<u8>) -> Self {
		Self(bytes::Bytes::from(v))
	}
}

impl From<Bytes> for bytes::Bytes {
	fn from(bytes: Bytes) -> Self {
		bytes.0
	}
}

impl From<bytes::Bytes> for Bytes {
	fn from(bytes: bytes::Bytes) -> Self {
		Bytes(bytes)
	}
}

impl From<lyxal_types_core::Bytes> for Bytes {
	fn from(v: lyxal_types_core::Bytes) -> Self {
		Bytes(v.into_inner())
	}
}

impl From<Bytes> for lyxal_types_core::Bytes {
	fn from(v: Bytes) -> Self {
		lyxal_types_core::Bytes::from(v.into_inner())
	}
}

impl Deref for Bytes {
	type Target = bytes::Bytes;

	fn deref(&self) -> &Self::Target {
		&self.0
	}
}

impl ToSql for Bytes {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "b\"{}\"", hex::encode_upper(&self.0))
	}
}

#[cfg(test)]
mod tests {
	use crate::lyxal_core_db::val::{Bytes, Value};

	#[test]
	fn serialize() {
		let val = Value::Bytes(Bytes::from(vec![1, 2, 3, 5]));
		let serialized: Vec<u8> = lyxal_revision::to_vec(&val).unwrap();
		println!("{serialized:?}");
		let deserialized: Value = lyxal_revision::from_slice(&serialized).unwrap();
		assert_eq!(val, deserialized);
	}
}
