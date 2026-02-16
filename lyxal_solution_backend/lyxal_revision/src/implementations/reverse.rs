use crate::DeserializeLyxalRevisioned;
use crate::SerializeLyxalRevisioned;

use super::super::Error;
use super::super::LyxalRevisioned;
use std::cmp::Reverse;

impl<T> SerializeLyxalRevisioned for Reverse<T>
where
	T: SerializeLyxalRevisioned,
{
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.0.serialize_lyxal_revisioned(writer)
	}
}

impl<T> DeserializeLyxalRevisioned for Reverse<T>
where
	T: DeserializeLyxalRevisioned,
{
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		Ok(Reverse(T::deserialize_lyxal_revisioned(reader)?))
	}
}

impl<T> LyxalRevisioned for Reverse<T>
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
	fn test_reverse() {
		let val: Reverse<u32> = Reverse(u32::MAX);
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 5);
		let out =
			<Reverse<u32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}
}

