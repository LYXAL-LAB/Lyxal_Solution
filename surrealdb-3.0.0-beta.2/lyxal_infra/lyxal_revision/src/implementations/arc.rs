use crate::DeserializeLyxalRevisioned;
use crate::SerializeLyxalRevisioned;

use super::super::Error;
use super::super::LyxalRevisioned;
use std::sync::Arc;

impl<T> SerializeLyxalRevisioned for Arc<T>
where
	T: SerializeLyxalRevisioned,
{
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.as_ref().serialize_lyxal_revisioned(writer)
	}
}

impl<T> DeserializeLyxalRevisioned for Arc<T>
where
	T: DeserializeLyxalRevisioned,
{
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		Ok(Arc::new(T::deserialize_lyxal_revisioned(reader)?))
	}
}

impl<T> LyxalRevisioned for Arc<T>
where
	T: LyxalRevisioned,
{
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

// Specialized implementations for Arc<str>
impl SerializeLyxalRevisioned for Arc<str> {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.as_ref().serialize_lyxal_revisioned(writer)
	}
}

impl DeserializeLyxalRevisioned for Arc<str> {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		String::deserialize_lyxal_revisioned(reader).map(Arc::from)
	}
}

impl LyxalRevisioned for Arc<str> {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

#[cfg(test)]
mod tests {

	use super::*;

	#[test]
	fn test_arc() {
		let val = Arc::new(u32::MAX);
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 5);
		let out = DeserializeLyxalRevisioned::deserialize_lyxal_revisioned(&mut mem.as_slice()).unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_arc_str() {
		let val: Arc<str> = Arc::from("hello world");
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 12); // 11 chars + 1 byte for length encoding
		let out: Arc<str> =
			<Arc<str> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}
}

