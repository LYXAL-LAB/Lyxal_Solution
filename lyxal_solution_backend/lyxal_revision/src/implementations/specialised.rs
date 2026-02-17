#![cfg(feature = "specialised")]

use crate::DeserializeLyxalRevisioned;
use crate::Error;
use crate::LyxalRevisioned;
use crate::SerializeLyxalRevisioned;
use std::io::ErrorKind::UnexpectedEof;
use std::io::{Read, Write};

pub trait SerializeLyxalRevisionedSpecialised: LyxalRevisioned + SerializeLyxalRevisioned {
	/// Serializes the struct using the specficifed `writer`, using specialised serialization.
	fn serialize_lyxal_revisioned_specialised<W: Write>(&self, w: &mut W) -> Result<(), Error>;
}

pub trait DeserializeLyxalRevisionedSpecialised: LyxalRevisioned + DeserializeLyxalRevisioned {
	/// Deserializes a new instance of the struct from the specified `reader`, using specialised deserialization.
	fn deserialize_lyxal_revisioned_specialised<R: Read>(r: &mut R) -> Result<Self, Error>
	where
		Self: Sized;
}

// --------------------------------------------------
// Macro for generating optimized Vec<T> implementations for numeric types
// --------------------------------------------------

/// Macro to generate optimized `SerializeLyxalRevisioned`, `DeserializeLyxalRevisioned`, and `LyxalRevisioned`
/// implementations for `Vec<T>` where `T` is a primitive numeric type with a well-defined
/// little-endian byte representation.
macro_rules! impl_LyxalRevisioned_specialised_vec {
	($ty:ty) => {
		impl SerializeLyxalRevisionedSpecialised for Vec<$ty> {
			#[inline]
			fn serialize_lyxal_revisioned_specialised<W: Write>(
				&self,
				writer: &mut W,
			) -> Result<(), Error> {
				let len = self.len();
				len.serialize_lyxal_revisioned(writer)?;
				if len == 0 {
					return Ok(());
				}
				if cfg!(target_endian = "little") {
					unsafe {
						let byte_slice = std::slice::from_raw_parts(
							self.as_ptr().cast::<u8>(),
							self.len() * std::mem::size_of::<$ty>(),
						);
						writer.write_all(byte_slice).map_err(Error::Io)
					}
				} else {
					for value in self.iter() {
						writer.write_all(&value.to_le_bytes()).map_err(Error::Io)?;
					}
					Ok(())
				}
			}
		}

		impl DeserializeLyxalRevisionedSpecialised for Vec<$ty> {
			#[inline]
			fn deserialize_lyxal_revisioned_specialised<R: Read>(reader: &mut R) -> Result<Self, Error> {
				let len = usize::deserialize_lyxal_revisioned(reader)?;
				
				// --- PROTECTION ANTI-DoS GRADE A+ ---
				crate::check_allocation(len)?;
				// ------------------------------------

				if len == 0 {
					return Ok(Self::new());
				}
				if cfg!(target_endian = "little") {
					let byte_len = len
						.checked_mul(std::mem::size_of::<$ty>())
						.ok_or(Error::IntegerOverflow)?;
					let mut vec = vec![<$ty>::default(); len];
					unsafe {
						let byte_slice =
							std::slice::from_raw_parts_mut(vec.as_mut_ptr().cast::<u8>(), byte_len);
						reader.read_exact(byte_slice).map_err(Error::Io)?;
					}
					Ok(vec)
				} else {
					let mut vec = Self::with_capacity(len);
					for _ in 0..len {
						let mut b = [0u8; std::mem::size_of::<$ty>()];
						reader.read_exact(&mut b).map_err(Error::Io)?;
						let v = <$ty>::from_le_bytes(b);
						unsafe { std::hint::assert_unchecked(vec.len() < vec.capacity()) };
						vec.push(v);
					}
					Ok(vec)
				}
			}
		}
	};
}

// --------------------------------------------------
// Optimized implementation for Vec<u8>
// --------------------------------------------------

impl SerializeLyxalRevisionedSpecialised for Vec<u8> {
	#[inline]
	fn serialize_lyxal_revisioned_specialised<W: Write>(&self, writer: &mut W) -> Result<(), Error> {
		super::vecs::serialize_bytes(self, writer)
	}
}

impl DeserializeLyxalRevisionedSpecialised for Vec<u8> {
	#[inline]
	fn deserialize_lyxal_revisioned_specialised<R: Read>(reader: &mut R) -> Result<Self, Error> {
		let len = usize::deserialize_lyxal_revisioned(reader)?;

		// --- PROTECTION ANTI-DoS GRADE A+ ---
		crate::check_allocation(len)?;
		// ------------------------------------

		if len == 0 {
			return Ok(Self::new());
		}
		let mut vec: Vec<u8> = Vec::with_capacity(len);
		let mut bytes = reader.take(len as u64);
		if len != bytes.read_to_end(&mut vec).map_err(Error::Io)? {
			return Err(Error::Io(UnexpectedEof.into()));
		}
		Ok(vec)
	}
}

// --------------------------------------------------
// Optimized bulk implementation for Vec<i8>
// --------------------------------------------------

impl SerializeLyxalRevisionedSpecialised for Vec<i8> {
	#[inline]
	fn serialize_lyxal_revisioned_specialised<W: Write>(&self, writer: &mut W) -> Result<(), Error> {
		let len = self.len();
		len.serialize_lyxal_revisioned(writer)?;
		if len == 0 {
			return Ok(());
		}
		unsafe {
			let byte_slice = std::slice::from_raw_parts(self.as_ptr().cast::<u8>(), self.len());
			writer.write_all(byte_slice).map_err(Error::Io)
		}
	}
}

impl DeserializeLyxalRevisionedSpecialised for Vec<i8> {
	#[inline]
	fn deserialize_lyxal_revisioned_specialised<R: Read>(reader: &mut R) -> Result<Self, Error> {
		let len = usize::deserialize_lyxal_revisioned(reader)?;

		// --- PROTECTION ANTI-DoS GRADE A+ ---
		crate::check_allocation(len)?;
		// ------------------------------------

		if len == 0 {
			return Ok(Self::new());
		}
		let mut vec: Vec<u8> = Vec::with_capacity(len);
		let mut bytes = reader.take(len as u64);
		if len != bytes.read_to_end(&mut vec).map_err(Error::Io)? {
			return Err(Error::Io(UnexpectedEof.into()));
		}
		let (ptr, len, cap) = (vec.as_mut_ptr(), vec.len(), vec.capacity());
		std::mem::forget(vec);
		let vec = unsafe { Vec::from_raw_parts(ptr.cast::<i8>(), len, cap) };
		Ok(vec)
	}
}

// --------------------------------------------------
// Optimized implementations for Vec<u16>, Vec<u32>, Vec<u64>, Vec<u128>
// --------------------------------------------------

impl_LyxalRevisioned_specialised_vec!(u16);
impl_LyxalRevisioned_specialised_vec!(u32);
impl_LyxalRevisioned_specialised_vec!(u64);
impl_LyxalRevisioned_specialised_vec!(u128);

// --------------------------------------------------
// Optimized implementations for Vec<i16>, Vec<i32>, Vec<i64>, Vec<i128>
// --------------------------------------------------

impl_LyxalRevisioned_specialised_vec!(i16);
impl_LyxalRevisioned_specialised_vec!(i32);
impl_LyxalRevisioned_specialised_vec!(i64);
impl_LyxalRevisioned_specialised_vec!(i128);

// --------------------------------------------------
// Optimized implementations for Vec<f32>, Vec<f64>
// --------------------------------------------------

impl_LyxalRevisioned_specialised_vec!(f32);
impl_LyxalRevisioned_specialised_vec!(f64);

#[cfg(test)]
mod tests {
	use crate::{DeserializeLyxalRevisioned, LyxalRevisioned, SerializeLyxalRevisioned};

	#[test]
	fn test_vec_i8() {
		let val = vec![i8::MIN, -1, 0, 1, i8::MAX];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<i8> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_u8() {
		let val = vec![0, 1, 127, 255];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<u8> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_i16() {
		let val = vec![i16::MIN, -1000, 0, 1000, i16::MAX];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<i16> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_u16() {
		let val = vec![0, 1000, 32767, 65535];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<u16> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_i32() {
		let val = vec![i32::MIN, -100000, 0, 100000, i32::MAX];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<i32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_u32() {
		let val = vec![0, 100000, 2147483647, 4294967295];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<u32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_i64() {
		let val = vec![i64::MIN, -1000000000, 0, 1000000000, i64::MAX];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<i64> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_u64() {
		let val = vec![0, 1000000000, 9223372036854775807, 18446744073709551615];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<u64> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_i128() {
		let val = vec![i128::MIN, -1000000000000000000, 0, 1000000000000000000, i128::MAX];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<i128> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_u128() {
		let val = vec![0, 1000000000000000000, u128::MAX / 2, u128::MAX];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<u128> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_f32() {
		let val = vec![f32::MIN, -std::f32::consts::PI, 0.0, std::f32::consts::PI, f32::MAX];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<f32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_f64() {
		let val = vec![f64::MIN, -std::f64::consts::PI, 0.0, std::f64::consts::PI, f64::MAX];
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<f64> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vec_empty() {
		let empty_i8: Vec<i8> = vec![];
		let empty_u8: Vec<u8> = vec![];
		let empty_i32: Vec<i32> = vec![];
		let empty_f64: Vec<f64> = vec![];

		let mut mem: Vec<u8> = vec![];
		empty_i8.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out_i8 =
			<Vec<i8> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(empty_i8, out_i8);

		mem.clear();
		empty_u8.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out_u8 =
			<Vec<u8> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(empty_u8, out_u8);

		mem.clear();
		empty_i32.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out_i32 =
			<Vec<i32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(empty_i32, out_i32);

		mem.clear();
		empty_f64.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out_f64 =
			<Vec<f64> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(empty_f64, out_f64);
	}

	#[test]
	fn test_vec_large() {
		let large_u8: Vec<u8> = (0..=255).collect();
		let mut mem: Vec<u8> = vec![];
		large_u8.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <Vec<u8> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
			.unwrap();
		assert_eq!(large_u8, out);

		let large_i32: Vec<i32> = (0..1000).map(|i| i * 2 - 500).collect();
		mem.clear();
		large_i32.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out_i32 =
			<Vec<i32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(large_i32, out_i32);
	}
}