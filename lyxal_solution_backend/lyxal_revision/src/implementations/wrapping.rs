use crate::DeserializeLyxalRevisioned;
use crate::SerializeLyxalRevisioned;

use super::super::Error;
use super::super::LyxalRevisioned;
use std::num::Wrapping;

impl<T> SerializeLyxalRevisioned for Wrapping<T>
where
	T: SerializeLyxalRevisioned,
{
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.0.serialize_lyxal_revisioned(writer)
	}
}

impl<T> DeserializeLyxalRevisioned for Wrapping<T>
where
	T: DeserializeLyxalRevisioned,
{
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		Ok(Wrapping(T::deserialize_lyxal_revisioned(reader)?))
	}
}

impl<T> LyxalRevisioned for Wrapping<T>
where
	T: LyxalRevisioned,
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
		let val: Wrapping<u32> = Wrapping(u32::MAX);
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 5);
		let out =
			<Wrapping<u32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}
}

