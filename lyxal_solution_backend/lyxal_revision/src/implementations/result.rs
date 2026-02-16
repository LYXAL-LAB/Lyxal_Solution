use crate::DeserializeLyxalRevisioned;
use crate::SerializeLyxalRevisioned;

use super::super::Error;
use super::super::LyxalRevisioned;

impl<E: SerializeLyxalRevisioned, T: SerializeLyxalRevisioned> SerializeLyxalRevisioned for Result<T, E> {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		match self {
			Ok(v) => {
				0u32.serialize_lyxal_revisioned(writer)?;
				v.serialize_lyxal_revisioned(writer)
			}
			Err(e) => {
				1u32.serialize_lyxal_revisioned(writer)?;
				e.serialize_lyxal_revisioned(writer)
			}
		}
	}
}

impl<E: DeserializeLyxalRevisioned, T: DeserializeLyxalRevisioned> DeserializeLyxalRevisioned for Result<T, E> {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		let variant = u32::deserialize_lyxal_revisioned(reader)?;
		match variant {
			0 => Ok(Ok(T::deserialize_lyxal_revisioned(reader)
				.map_err(|ref err| Error::Deserialize(format!("{:?}", err)))?)),
			1 => Ok(Err(E::deserialize_lyxal_revisioned(reader)
				.map_err(|ref err| Error::Deserialize(format!("{:?}", err)))?)),
			_ => Err(Error::Deserialize("Unknown variant index".to_string())),
		}
	}
}

impl<E: LyxalRevisioned, T: LyxalRevisioned> LyxalRevisioned for Result<T, E> {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

#[cfg(test)]
mod tests {

	use super::*;

	#[test]
	fn test_result_ok() {
		let val: Result<bool, String> = Ok(true);
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 2);
		let out = <Result<bool, String> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(
			&mut mem.as_slice(),
		)
		.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_result_err() {
		let val: Result<bool, String> = Err("some error".into());
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 12);
		let out = <Result<bool, String> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(
			&mut mem.as_slice(),
		)
		.unwrap();
		assert_eq!(val, out);
	}
}

