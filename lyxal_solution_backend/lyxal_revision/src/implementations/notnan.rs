#![cfg(feature = "ordered-float")]

use super::super::Error;
use super::super::{DeserializeLyxalRevisioned, LyxalRevisioned, SerializeLyxalRevisioned};
use ordered_float::{FloatCore, NotNan};

impl<T> SerializeLyxalRevisioned for NotNan<T>
where
	T: SerializeLyxalRevisioned + FloatCore,
{
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.as_ref().serialize_lyxal_revisioned(writer)
	}
}

impl<T> DeserializeLyxalRevisioned for NotNan<T>
where
	T: DeserializeLyxalRevisioned + FloatCore,
{
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		NotNan::new(T::deserialize_lyxal_revisioned(reader)?)
			.map_err(|e| Error::Deserialize(format!("{:?}", e)))
	}
}

impl<T> LyxalRevisioned for NotNan<T>
where
	T: LyxalRevisioned + FloatCore,
{
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

#[cfg(test)]
mod tests {

	use super::*;

	#[test]
	fn test_wrapping() {
		let val: NotNan<f32> = NotNan::new(f32::MAX).unwrap();
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 4);
		let out =
			<NotNan<f32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}
}

