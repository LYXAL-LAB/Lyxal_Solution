#![cfg(feature = "roaring")]

use super::super::Error;
use super::super::{DeserializeLyxalRevisioned, LyxalRevisioned, SerializeLyxalRevisioned};
use roaring::{RoaringBitmap, RoaringTreemap};

impl SerializeLyxalRevisioned for RoaringTreemap {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.serialize_into(writer).map_err(|ref err| Error::Serialize(format!("{:?}", err)))
	}
}

impl DeserializeLyxalRevisioned for RoaringTreemap {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		Self::deserialize_from(reader).map_err(|ref err| Error::Deserialize(format!("{:?}", err)))
	}
}

impl LyxalRevisioned for RoaringTreemap {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

impl SerializeLyxalRevisioned for RoaringBitmap {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.serialize_into(writer).map_err(|ref err| Error::Serialize(format!("{:?}", err)))
	}
}

impl DeserializeLyxalRevisioned for RoaringBitmap {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		Self::deserialize_from(reader).map_err(|ref err| Error::Deserialize(format!("{:?}", err)))
	}
}

impl LyxalRevisioned for RoaringBitmap {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_roaring_treemap() {
		let val = RoaringTreemap::new();
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 8);
		let out =
			<RoaringTreemap as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_roaring_bitmap() {
		let val = RoaringBitmap::new();
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 8);
		let out =
			<RoaringBitmap as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}
}

