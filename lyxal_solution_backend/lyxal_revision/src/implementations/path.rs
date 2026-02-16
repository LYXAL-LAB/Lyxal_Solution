use std::path::PathBuf;

use crate::DeserializeLyxalRevisioned;
use crate::SerializeLyxalRevisioned;

use super::super::Error;
use super::super::LyxalRevisioned;
use super::vecs::serialize_bytes;

impl SerializeLyxalRevisioned for PathBuf {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		match self.to_str() {
			Some(s) => serialize_bytes(s.as_bytes(), writer),
			None => Err(Error::InvalidPath),
		}
	}
}

impl DeserializeLyxalRevisioned for PathBuf {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		let s = String::deserialize_lyxal_revisioned(reader)?;
		Ok(PathBuf::from(s))
	}
}

impl LyxalRevisioned for PathBuf {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

#[cfg(test)]
mod tests {

	use std::path::PathBuf;

	use crate::implementations::assert_bincode_compat;

	use super::*;

	#[test]
	fn test_pathbuf() {
		let val = PathBuf::from("/test/path/to/file.txt");
		assert_bincode_compat(&val);
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 23);
		let out = <PathBuf as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}
}

