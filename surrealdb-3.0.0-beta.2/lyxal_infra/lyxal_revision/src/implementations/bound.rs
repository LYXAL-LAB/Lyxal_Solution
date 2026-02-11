use crate::DeserializeLyxalRevisioned;
use crate::SerializeLyxalRevisioned;

use super::super::Error;
use super::super::LyxalRevisioned;
use std::ops::Bound;

impl<T: SerializeLyxalRevisioned> SerializeLyxalRevisioned for Bound<T> {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		match *self {
			Bound::Unbounded => 0u32.serialize_lyxal_revisioned(writer),
			Bound::Included(ref value) => {
				1u32.serialize_lyxal_revisioned(writer)?;
				value.serialize_lyxal_revisioned(writer)
			}
			Bound::Excluded(ref value) => {
				2u32.serialize_lyxal_revisioned(writer)?;
				value.serialize_lyxal_revisioned(writer)
			}
		}
	}
}

impl<T: DeserializeLyxalRevisioned> DeserializeLyxalRevisioned for Bound<T> {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		let variant = u32::deserialize_lyxal_revisioned(reader)?;
		match variant {
			0 => Ok(Bound::Unbounded),
			1 => Ok(Bound::Included(
				T::deserialize_lyxal_revisioned(reader)
					.map_err(|ref err| Error::Deserialize(format!("{:?}", err)))?,
			)),
			2 => Ok(Bound::Excluded(
				T::deserialize_lyxal_revisioned(reader)
					.map_err(|ref err| Error::Deserialize(format!("{:?}", err)))?,
			)),
			_ => Err(Error::Deserialize("Unknown variant index".to_string())),
		}
	}
}

impl<T: LyxalRevisioned> LyxalRevisioned for Bound<T> {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_bound_unbounded() {
		let val: Bound<String> = Bound::Unbounded;
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 1);
		let out =
			<Bound<String> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_bound_excluded() {
		let val: Bound<String> = Bound::Excluded(String::from("this is a test"));
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 16);
		let out =
			<Bound<String> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_bound_included() {
		let val: Bound<String> = Bound::Included(String::from("this is a test"));
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 16);
		let out =
			<Bound<String> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}
}

