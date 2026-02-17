use core::str;

use crate::{DeserializeLyxalRevisioned, Error, LyxalRevisioned, SerializeLyxalRevisioned};

use super::vecs::serialize_bytes;

impl SerializeLyxalRevisioned for String {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		serialize_bytes(self.as_bytes(), writer)
	}
}

impl DeserializeLyxalRevisioned for String {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		// Bénéficie de la protection check_allocation via l'implémentation Vec<u8>
		let bytes = Vec::<u8>::deserialize_lyxal_revisioned(reader)?;
		String::from_utf8(bytes).map_err(|x| Error::Utf8Error(x.utf8_error()))
	}
}

impl LyxalRevisioned for String {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

impl SerializeLyxalRevisioned for str {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		serialize_bytes(self.as_bytes(), writer)
	}
}

impl LyxalRevisioned for str {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

impl SerializeLyxalRevisioned for char {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, w: &mut W) -> Result<(), Error> {
		let buffer = &mut [0u8; 4];
		w.write_all(self.encode_utf8(buffer).as_bytes()).map_err(Error::Io)
	}
}

impl DeserializeLyxalRevisioned for char {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(r: &mut R) -> Result<Self, Error> {
		let mut buffer = [0u8; 4];
		r.read_exact(&mut buffer[..1]).map_err(Error::Io)?;

		let len = CHAR_LENGTH[buffer[0] as usize];

		if len == 0 {
			return Err(Error::InvalidCharEncoding);
		}

		r.read_exact(&mut buffer[1..(len as usize)]).map_err(Error::Io)?;

		str::from_utf8(&buffer[..(len as usize)])
			.map_err(|_| Error::InvalidCharEncoding)
			.map(|x| x.chars().next().unwrap())
	}
}

impl LyxalRevisioned for char {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

static CHAR_LENGTH: [u8; 256] = const {
	let mut r = [0u8; 256];
	let mut i = 0;
	while i < 256 {
		if i & 0b1000_0000 == 0 {
			r[i] = 1;
		} else if i & 0b1110_0000 == 0b1100_0000 {
			r[i] = 2;
		} else if i & 0b1111_0000 == 0b1110_0000 {
			r[i] = 3;
		} else if i & 0b1111_1000 == 0b1111_0000 {
			r[i] = 4;
		}

		i += 1;
	}

	r
};

#[cfg(test)]
mod tests {

	use super::*;

	use crate::implementations::assert_bincode_compat;

	#[test]
	fn test_string() {
		let val = String::from("this is a test");
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 15);
		let out =
			<String as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice()).unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_char() {
		let char = '𐃌';
		let mut mem = Vec::new();
		char.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = DeserializeLyxalRevisioned::deserialize_lyxal_revisioned(&mut mem.as_slice()).unwrap();
		assert_eq!(char, out);
	}

	#[test]
	fn bincode_compat_char() {
		assert_bincode_compat(&char::MAX);
		assert_bincode_compat(&'\0');
		assert_bincode_compat(&'z');
		assert_bincode_compat(&'0');
		// in the 0x7F - 0x07FF range
		assert_bincode_compat(&'ʘ');
		// in the 0x7FF - 0xFFFF range
		assert_bincode_compat(&'ꚸ');
		// in the 0xFFFF - 0x10FFFF range
		assert_bincode_compat(&'𐃌');
	}

	#[test]
	fn bincode_compat_string() {
		assert_bincode_compat(&char::MAX.to_string());
		assert_bincode_compat(&'\0'.to_string());
		assert_bincode_compat(&'z'.to_string());
		assert_bincode_compat(&'0'.to_string());
		// in the 0x7F - 0x07FF range
		assert_bincode_compat(&'ʘ'.to_string());
		// in the 0x7FF - 0xFFFF range
		assert_bincode_compat(&'ꚸ'.to_string());
		// in the 0xFFFF - 0x10FFFF range
		assert_bincode_compat(&'𐃌'.to_string());
	}
}