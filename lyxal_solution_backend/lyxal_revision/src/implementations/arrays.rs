use crate::DeserializeLyxalRevisioned;
use crate::Error;
use crate::LyxalRevisioned;
use crate::SerializeLyxalRevisioned;

macro_rules! impl_LyxalRevisioned_array_with_size {
	($ty:literal) => {
		impl<T> SerializeLyxalRevisioned for [T; $ty]
		where
			T: Copy + Default + SerializeLyxalRevisioned,
		{
			#[inline]
			fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
				for element in self {
					element.serialize_lyxal_revisioned(writer)?;
				}
				Ok(())
			}
		}

		impl<T> DeserializeLyxalRevisioned for [T; $ty]
		where
			T: Copy + Default + DeserializeLyxalRevisioned,
		{
			#[inline]
			fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
				let mut array = [T::default(); $ty];
				for i in 0..$ty {
					array[i] = T::deserialize_lyxal_revisioned(reader)?;
				}
				Ok(array)
			}
		}

		impl<T> LyxalRevisioned for [T; $ty]
		where
			T: Copy + Default + LyxalRevisioned,
		{
			#[inline]
			fn lyxal_revision() -> u16 {
				1
			}
		}
	};
}

macro_rules! impl_LyxalRevisioned_arrays {
    ($($N:literal)+) => {
        $(
            impl_LyxalRevisioned_array_with_size!($N);
        )+
    }
}

impl_LyxalRevisioned_arrays! {
	1  2  3  4  5  6  7  8  9 10
   11 12 13 14 15 16 17 18 19 20
   21 22 23 24 25 26 27 28 29 30
   31 32
}

