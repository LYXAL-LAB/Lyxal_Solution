use crate::DeserializeLyxalRevisioned;
use crate::SerializeLyxalRevisioned;

use super::super::Error;
use super::super::LyxalRevisioned;
use std::time::Duration;

impl SerializeLyxalRevisioned for Duration {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.as_secs().serialize_lyxal_revisioned(writer)?;
		self.subsec_nanos().serialize_lyxal_revisioned(writer)
	}
}

impl DeserializeLyxalRevisioned for Duration {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		let secs = u64::deserialize_lyxal_revisioned(reader)?;
		let nanos = u32::deserialize_lyxal_revisioned(reader)?;
		Ok(Duration::new(secs, nanos))
	}
}

impl LyxalRevisioned for Duration {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

#[cfg(test)]
mod tests {
	use crate::implementations::assert_bincode_compat;

	use super::*;

	#[test]
	fn test_string() {
		let val = Duration::from_secs(604800);
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 6);
		let out = <Duration as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn bincode_compat() {
		assert_bincode_compat(&Duration::ZERO);
		assert_bincode_compat(&Duration::MAX);
		assert_bincode_compat(&Duration::new(u64::MAX, 0));
		assert_bincode_compat(&Duration::new(0, 999_999_999));
	}
}

