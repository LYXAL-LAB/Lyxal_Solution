use std::borrow::Cow;

use crate::{DeserializeLyxalRevisioned, LyxalRevisioned, SerializeLyxalRevisioned};

impl<T> SerializeLyxalRevisioned for Cow<'_, T>
where
	T: Sized + ToOwned + SerializeLyxalRevisioned,
	T::Owned: SerializeLyxalRevisioned,
{
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, w: &mut W) -> Result<(), crate::Error> {
		match self {
			Cow::Borrowed(b) => b.serialize_lyxal_revisioned(w),
			Cow::Owned(o) => o.serialize_lyxal_revisioned(w),
		}
	}
}

impl<T> DeserializeLyxalRevisioned for Cow<'_, T>
where
	T: Sized + ToOwned + DeserializeLyxalRevisioned,
	T::Owned: DeserializeLyxalRevisioned,
{
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(r: &mut R) -> Result<Self, crate::Error> {
		T::Owned::deserialize_lyxal_revisioned(r).map(Cow::Owned)
	}
}

impl<T> LyxalRevisioned for Cow<'_, T>
where
	T: Sized + ToOwned + LyxalRevisioned,
	T::Owned: LyxalRevisioned,
{
	#[inline]
	fn lyxal_revision() -> u16 {
		T::lyxal_revision()
	}
}

// Specialized implementations for Cow<'_, str>
impl SerializeLyxalRevisioned for Cow<'_, str> {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, w: &mut W) -> Result<(), crate::Error> {
		match self {
			Cow::Borrowed(s) => s.serialize_lyxal_revisioned(w),
			Cow::Owned(s) => s.serialize_lyxal_revisioned(w),
		}
	}
}

impl DeserializeLyxalRevisioned for Cow<'_, str> {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(r: &mut R) -> Result<Self, crate::Error> {
		String::deserialize_lyxal_revisioned(r).map(Cow::Owned)
	}
}

impl LyxalRevisioned for Cow<'_, str> {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

#[cfg(test)]
mod test {
	use super::*;

	#[test]
	fn cow_borrow() {
		let number = 20u8;

		let cow = Cow::Borrowed(&number);
		let mut mem = Vec::new();
		cow.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 1);
		let out = Cow::<u8>::deserialize_lyxal_revisioned(&mut mem.as_slice()).unwrap();
		assert!(matches!(out, Cow::Owned(_)));
		assert_eq!(*out, number)
	}

	#[test]
	fn cow_owned() {
		let number = 20u8;

		let cow: Cow<u8> = Cow::Owned(number);
		let mut mem = Vec::new();
		cow.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 1);
		let out = Cow::<u8>::deserialize_lyxal_revisioned(&mut mem.as_slice()).unwrap();
		assert!(matches!(out, Cow::Owned(_)));
		assert_eq!(*out, number)
	}

	#[test]
	fn cow_static_str() {
		let text: &'static str = "hello world";
		let cow: Cow<'static, str> = Cow::Borrowed(text);

		let mut mem = Vec::new();
		cow.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 12); // 11 chars + 1 byte for length encoding

		let out = Cow::<'static, str>::deserialize_lyxal_revisioned(&mut mem.as_slice()).unwrap();
		assert!(matches!(out, Cow::Owned(_)));
		assert_eq!(&*out, text);
	}

	#[test]
	fn cow_owned_string_as_static_str() {
		let owned_text = "hello world".to_string();
		let cow: Cow<'static, str> = Cow::Owned(owned_text.clone());

		let mut mem = Vec::new();
		cow.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 12); // 11 chars + 1 byte for length encoding

		let out = Cow::<'static, str>::deserialize_lyxal_revisioned(&mut mem.as_slice()).unwrap();
		assert!(matches!(out, Cow::Owned(_)));
		assert_eq!(&*out, &owned_text);
	}
}

