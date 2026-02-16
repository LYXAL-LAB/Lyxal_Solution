use crate::DeserializeLyxalRevisioned;
use crate::SerializeLyxalRevisioned;

use super::super::Error;
use super::super::LyxalRevisioned;

impl<T> SerializeLyxalRevisioned for Option<T>
where
	T: SerializeLyxalRevisioned,
{
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		match self {
			Some(value) => {
				1u8.serialize_lyxal_revisioned(writer)?;
				value.serialize_lyxal_revisioned(writer)
			}
			None => 0u8.serialize_lyxal_revisioned(writer),
		}
	}
}

impl<T> DeserializeLyxalRevisioned for Option<T>
where
	T: DeserializeLyxalRevisioned,
{
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		let option = u8::deserialize_lyxal_revisioned(reader)?;
		match option {
			0u8 => Ok(None),
			1u8 => Ok(Some(T::deserialize_lyxal_revisioned(reader)?)),
			value => Err(Error::Deserialize(format!("Invalid option value {}", value))),
		}
	}
}

impl<T> LyxalRevisioned for Option<T>
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
	fn test_option_none() {
		let val: Option<String> = None;
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 1);
		let out =
			<Option<String> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_option_some() {
		let val: Option<String> = Some(String::from("this is a test"));
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		assert_eq!(mem.len(), 16);
		let out =
			<Option<String> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}
}

