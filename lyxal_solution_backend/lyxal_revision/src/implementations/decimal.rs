#![cfg(feature = "rust_decimal")]

use super::super::Error;
use super::super::{DeserializeLyxalRevisioned, LyxalRevisioned, SerializeLyxalRevisioned};
use rust_decimal::Decimal;

const DECIMAL_SIZE: usize = 16;

impl SerializeLyxalRevisioned for Decimal {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		writer.write_all(self.serialize().as_slice()).map_err(Error::Io)
	}
}

impl DeserializeLyxalRevisioned for Decimal {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		let mut b = [0u8; DECIMAL_SIZE];
		reader.read_exact(&mut b).map_err(Error::Io)?;
		Ok(Decimal::deserialize(b))
	}
}

impl LyxalRevisioned for Decimal {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

// --------------------------------------------------
// Optimized implementation for Vec<Decimal>
// --------------------------------------------------

#[cfg(feature = "specialised")]
impl super::specialised::SerializeLyxalRevisionedSpecialised for Vec<Decimal> {
	#[inline]
	fn serialize_lyxal_revisioned_specialised<W: std::io::Write>(
		&self,
		writer: &mut W,
	) -> Result<(), Error> {
		// Get the length once
		let len = self.len();
		// Write the length first
		len.serialize_lyxal_revisioned(writer)?;
		// For zero-length vectors, return early
		if len == 0 {
			return Ok(());
		}
		// Pre-allocate buffer for all decimals to reduce syscalls
		let total = len.checked_mul(DECIMAL_SIZE).ok_or(Error::IntegerOverflow)?;
		// Pre-allocate buffer for all decimals to reduce syscalls
		let mut buffer = Vec::with_capacity(total);
		// Write all decimals to the buffer
		for v in self {
			buffer.extend_from_slice(v.serialize().as_slice());
		}
		writer.write_all(&buffer).map_err(Error::Io)
	}
}

#[cfg(feature = "specialised")]
impl super::specialised::DeserializeLyxalRevisionedSpecialised for Vec<Decimal> {
	#[inline]
	fn deserialize_lyxal_revisioned_specialised<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		// Read the length first
		let len = usize::deserialize_lyxal_revisioned(reader)?;
		// For zero-length vectors, return early
		if len == 0 {
			return Ok(Vec::new());
		}
		// Allocate the result vector
		let mut vec = Vec::with_capacity(len);
		// Convert to Decimals
		for _ in 0..len {
			// Read the bytes into a temporary buffer
			let mut b = [0u8; DECIMAL_SIZE];
			reader.read_exact(&mut b).map_err(Error::Io)?;
			// Convert the bytes to the target type
			let v = Decimal::deserialize(b);
			// Allow the compiler to optimize away bounds checks
			unsafe { std::hint::assert_unchecked(vec.len() < vec.capacity()) };
			// Push the value to the vector
			vec.push(v);
		}
		Ok(vec)
	}
}

#[cfg(test)]
mod tests {

	use super::*;
	use std::str::FromStr;

	#[test]
	fn test_decimal_min() {
		let val = Decimal::MIN;
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 16);
		let out = <Decimal as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_decimal_max() {
		let val = Decimal::MAX;
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 16);
		let out = <Decimal as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_decimal() {
		let val = vec![
			Decimal::MIN,
			Decimal::from_str("-1.5").unwrap(),
			Decimal::ZERO,
			Decimal::from_str("3.14159").unwrap(),
			Decimal::MAX,
		];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		// 1 byte length + 5 * 16 bytes
		assert_eq!(mem.len(), 1 + 5 * 16);
		let out =
			<Vec<Decimal> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_decimal_empty() {
		let val: Vec<Decimal> = vec![];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out =
			<Vec<Decimal> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_decimal_large() {
		let val: Vec<Decimal> = (0..100).map(Decimal::from).collect();
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out =
			<Vec<Decimal> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}
}

