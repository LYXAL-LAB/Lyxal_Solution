#![cfg(feature = "regex")]

use super::super::Error;
use super::super::{DeserializeLyxalRevisioned, LyxalRevisioned, SerializeLyxalRevisioned};
use super::vecs::serialize_bytes;
use regex::Regex;

impl SerializeLyxalRevisioned for Regex {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		serialize_bytes(self.as_str().as_bytes(), writer)
	}
}

impl DeserializeLyxalRevisioned for Regex {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		let s = String::deserialize_lyxal_revisioned(reader)?;
		s.parse().map_err(|_| Error::Deserialize("invalid regex".to_string()))
	}
}

impl LyxalRevisioned for Regex {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_regex() {
		let val = Regex::new("/this ([a-z]+) a tes?/").unwrap();
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 23);
		let out =
			<Regex as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice()).unwrap();
		assert_eq!(val.as_str(), out.as_str());
	}
}

