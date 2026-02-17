//! Defines a generic trait for version tolerant serialization and deserialization
//! and implements it for primitive data types using the `bincode` format.

pub mod error;
pub mod implementations;

pub use crate::error::Error;
pub use lyxal_revision_derive::lyxal_revisioned;
pub use lyxal_revision_derive::lyxal_revisioned as revisioned;

use std::any::TypeId;
use std::io::{Read, Write};

/// Limite d'allocation maximale (par défaut 1 Go).
/// Utilisé pour prévenir les attaques par déni de service (DoS) lors de la désérialisation.
pub const MAX_ALLOCATION: usize = 1024 * 1024 * 1024;

/// Vérifie si une taille d'allocation est autorisée.
#[inline]
pub fn check_allocation(size: usize) -> Result<(), Error> {
	if size > MAX_ALLOCATION {
		return Err(Error::ExceededMaxAllocation(MAX_ALLOCATION));
	}
	Ok(())
}

pub mod prelude {
	pub use crate::{DeserializeLyxalRevisioned, SerializeLyxalRevisioned, lyxal_revisioned};
	pub use crate::{DeserializeRevisioned, SerializeRevisioned, revisioned};
}

/// Trait that provides an interface for version aware serialization and deserialization.
pub trait LyxalRevisioned {
	/// Returns the current lyxal_revision of this type.
	fn lyxal_revision() -> u16;
	/// Returns the current revision of this type (compatibility alias).
	fn revision() -> u16 {
		Self::lyxal_revision()
	}
	/// Returns the type id of this type.
	#[inline]
	fn type_id() -> std::any::TypeId
	where
		Self: 'static,
	{
		TypeId::of::<Self>()
	}
}

pub use LyxalRevisioned as Revisioned;

pub trait SerializeLyxalRevisioned: LyxalRevisioned {
	/// Serializes the struct using the specified `writer`.
	fn serialize_lyxal_revisioned<W: Write>(&self, w: &mut W) -> Result<(), Error>;

	/// Compatibility alias for serialization.
	fn serialize_revisioned<W: Write>(&self, w: &mut W) -> Result<(), Error> {
		self.serialize_lyxal_revisioned(w)
	}
}

pub use SerializeLyxalRevisioned as SerializeRevisioned;

pub trait DeserializeLyxalRevisioned: LyxalRevisioned {
	/// Deserializes a new instance of the struct from the specified `reader`.
	fn deserialize_lyxal_revisioned<R: Read>(r: &mut R) -> Result<Self, Error>
	where
		Self: Sized;

	/// Compatibility alias for deserialization.
	fn deserialize_revisioned<R: Read>(r: &mut R) -> Result<Self, Error>
	where
		Self: Sized
	{
		Self::deserialize_lyxal_revisioned(r)
	}
}

pub use DeserializeLyxalRevisioned as DeserializeRevisioned;

/// Deserialize a revisioned type from a reader
#[inline]
pub fn from_reader<R, T>(rdr: &mut R) -> Result<T, Error>
where
	R: Read,
	T: DeserializeLyxalRevisioned,
{
	DeserializeLyxalRevisioned::deserialize_lyxal_revisioned(rdr)
}

/// Deserialize a revisioned type from a slice of bytes
#[inline]
pub fn from_slice<T>(mut bytes: &[u8]) -> Result<T, Error>
where
	T: DeserializeLyxalRevisioned,
{
	DeserializeLyxalRevisioned::deserialize_lyxal_revisioned(&mut bytes)
}

/// Serialize a revisioned type into a vec of bytes
#[inline]
pub fn to_writer<W, T>(writer: &mut W, t: &T) -> Result<(), Error>
where
	W: Write,
	T: SerializeLyxalRevisioned,
{
	SerializeLyxalRevisioned::serialize_lyxal_revisioned(t, writer)
}

/// Serialize a revisioned type into a vec of bytes
#[inline]
pub fn to_vec<T>(t: &T) -> Result<Vec<u8>, Error>
where
	T: SerializeLyxalRevisioned,
{
	let mut res = Vec::new();
	SerializeLyxalRevisioned::serialize_lyxal_revisioned(t, &mut res)?;
	Ok(res)
}