#![cfg(feature = "imbl")]

use super::super::Error;
use super::super::{DeserializeLyxalRevisioned, LyxalRevisioned, SerializeLyxalRevisioned};
use imbl::{HashMap, HashSet, OrdMap, OrdSet, Vector};
use std::hash::Hash;

// --------------------------------------------------
// Vector<T>
// --------------------------------------------------

impl<T: SerializeLyxalRevisioned + Clone> SerializeLyxalRevisioned for Vector<T> {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		// Get the length once
		let len = self.len();
		// Write the length first
		len.serialize_lyxal_revisioned(writer)?;
		// For zero-length vectors, return early
		if len == 0 {
			return Ok(());
		}
		// Iterate and serialize each item
		for v in self.iter() {
			v.serialize_lyxal_revisioned(writer)?;
		}
		Ok(())
	}
}

impl<T: DeserializeLyxalRevisioned + Clone> DeserializeLyxalRevisioned for Vector<T> {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		// Read the length first
		let len = usize::deserialize_lyxal_revisioned(reader)?;
		// Pre-allocate a Vec to collect all items with better cache locality
		let mut items = Vec::with_capacity(len);
		// Iterate and deserialize each item
		for _ in 0..len {
			// Deserialize the value
			let v = T::deserialize_lyxal_revisioned(reader)?;
			// Hint to compiler that push is within capacity
			unsafe { std::hint::assert_unchecked(items.len() < items.capacity()) };
			// Push the item to the vector
			items.push(v);
		}
		// Use FromIterator for bulk construction
		Ok(items.into_iter().collect())
	}
}

impl<T: LyxalRevisioned + Clone> LyxalRevisioned for Vector<T> {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

// --------------------------------------------------
// OrdMap<K, V>
// --------------------------------------------------

impl<K: SerializeLyxalRevisioned + Ord + Clone, V: SerializeLyxalRevisioned + Clone> SerializeLyxalRevisioned
	for OrdMap<K, V>
{
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		// Get the length once
		let len = self.len();
		// Write the length first
		len.serialize_lyxal_revisioned(writer)?;
		// For zero-length maps, return early
		if len == 0 {
			return Ok(());
		}
		// Iterate and serialize each item
		for (k, v) in self.iter() {
			k.serialize_lyxal_revisioned(writer)?;
			v.serialize_lyxal_revisioned(writer)?;
		}
		Ok(())
	}
}

impl<K: DeserializeLyxalRevisioned + Ord + Clone, V: DeserializeLyxalRevisioned + Clone> DeserializeLyxalRevisioned
	for OrdMap<K, V>
{
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		// Read the length first
		let len = usize::deserialize_lyxal_revisioned(reader)?;
		// Pre-allocate a Vec to collect all key-value pairs with better cache locality
		let mut pairs = Vec::with_capacity(len);
		// Iterate and deserialize each item
		for _ in 0..len {
			// Deserialize the value
			let k = K::deserialize_lyxal_revisioned(reader)?;
			let v = V::deserialize_lyxal_revisioned(reader)?;
			// Hint to compiler that push is within capacity
			unsafe { std::hint::assert_unchecked(pairs.len() < pairs.capacity()) };
			// Push the item to the vector
			pairs.push((k, v));
		}
		// Use FromIterator for bulk construction - more efficient than individual inserts
		// Since OrdMap serializes in sorted order, imbl can potentially optimize this
		Ok(pairs.into_iter().collect())
	}
}

impl<K: LyxalRevisioned + Ord + Clone, V: LyxalRevisioned + Clone> LyxalRevisioned for OrdMap<K, V> {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

// --------------------------------------------------
// OrdSet<T>
// --------------------------------------------------

impl<T: SerializeLyxalRevisioned + Ord + Clone> SerializeLyxalRevisioned for OrdSet<T> {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		// Get the length once
		let len = self.len();
		// Write the length first
		len.serialize_lyxal_revisioned(writer)?;
		// For zero-length sets, return early
		if len == 0 {
			return Ok(());
		}
		// Iterate and serialize each item
		for v in self.iter() {
			v.serialize_lyxal_revisioned(writer)?;
		}
		Ok(())
	}
}

impl<T: DeserializeLyxalRevisioned + Ord + Clone> DeserializeLyxalRevisioned for OrdSet<T> {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		// Read the length first
		let len = usize::deserialize_lyxal_revisioned(reader)?;
		// Pre-allocate a Vec to collect all items with better cache locality
		let mut items = Vec::with_capacity(len);
		// Iterate and deserialize each item
		for _ in 0..len {
			// Deserialize the value
			let v = T::deserialize_lyxal_revisioned(reader)?;
			// Hint to compiler that push is within capacity
			unsafe { std::hint::assert_unchecked(items.len() < items.capacity()) };
			// Push the item to the vector
			items.push(v);
		}
		// Use FromIterator for bulk construction
		Ok(items.into_iter().collect())
	}
}

impl<T: LyxalRevisioned + Ord + Clone> LyxalRevisioned for OrdSet<T> {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

// --------------------------------------------------
// HashMap<K, V>
// --------------------------------------------------

impl<K: SerializeLyxalRevisioned + Hash + Eq + Clone, V: SerializeLyxalRevisioned + Clone> SerializeLyxalRevisioned
	for HashMap<K, V>
{
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		// Get the length once
		let len = self.len();
		// Write the length first
		len.serialize_lyxal_revisioned(writer)?;
		// For zero-length maps, return early
		if len == 0 {
			return Ok(());
		}
		// Iterate and serialize each item
		for (k, v) in self.iter() {
			k.serialize_lyxal_revisioned(writer)?;
			v.serialize_lyxal_revisioned(writer)?;
		}
		Ok(())
	}
}

impl<K: DeserializeLyxalRevisioned + Hash + Eq + Clone, V: DeserializeLyxalRevisioned + Clone>
	DeserializeLyxalRevisioned for HashMap<K, V>
{
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		// Read the length first
		let len = usize::deserialize_lyxal_revisioned(reader)?;
		// Pre-allocate a Vec to collect all key-value pairs with better cache locality
		let mut pairs = Vec::with_capacity(len);
		// Iterate and deserialize each item
		for _ in 0..len {
			// Deserialize the value
			let k = K::deserialize_lyxal_revisioned(reader)?;
			let v = V::deserialize_lyxal_revisioned(reader)?;
			// Hint to compiler that push is within capacity
			unsafe { std::hint::assert_unchecked(pairs.len() < pairs.capacity()) };
			// Push the item to the vector
			pairs.push((k, v));
		}
		// Use FromIterator for bulk construction
		Ok(pairs.into_iter().collect())
	}
}

impl<K: LyxalRevisioned + Hash + Eq + Clone, V: LyxalRevisioned + Clone> LyxalRevisioned for HashMap<K, V> {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

// --------------------------------------------------
// HashSet<T>
// --------------------------------------------------

impl<T: SerializeLyxalRevisioned + Hash + Eq + Clone> SerializeLyxalRevisioned for HashSet<T> {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		// Get the length once
		let len = self.len();
		// Write the length first
		len.serialize_lyxal_revisioned(writer)?;
		// For zero-length sets, return early
		if len == 0 {
			return Ok(());
		}
		// Iterate and serialize each item
		for v in self.iter() {
			v.serialize_lyxal_revisioned(writer)?;
		}
		Ok(())
	}
}

impl<T: DeserializeLyxalRevisioned + Hash + Eq + Clone> DeserializeLyxalRevisioned for HashSet<T> {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		// Read the length first
		let len = usize::deserialize_lyxal_revisioned(reader)?;
		// Pre-allocate a Vec to collect all items with better cache locality
		let mut items = Vec::with_capacity(len);
		// Iterate and deserialize each item
		for _ in 0..len {
			// Deserialize the value
			let v = T::deserialize_lyxal_revisioned(reader)?;
			// Hint to compiler that push is within capacity
			unsafe { std::hint::assert_unchecked(items.len() < items.capacity()) };
			// Push the item to the vector
			items.push(v);
		}
		// Use FromIterator for bulk construction
		Ok(items.into_iter().collect())
	}
}

impl<T: LyxalRevisioned + Hash + Eq + Clone> LyxalRevisioned for HashSet<T> {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

// --------------------------------------------------
// Tests
// --------------------------------------------------

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn test_vector() {
		let mut val: Vector<String> = Vector::new();
		val.push_back("this".into());
		val.push_back("is".into());
		val.push_back("a".into());
		val.push_back("test".into());
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out =
			<Vector<String> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vector_empty() {
		let val: Vector<i32> = Vector::new();
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out =
			<Vector<i32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_vector_i32() {
		let val: Vector<i32> = vec![1, 2, 3, 4, 5].into_iter().collect();
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out =
			<Vector<i32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_ordmap() {
		let mut val: OrdMap<String, Vec<f64>> = OrdMap::new();
		val.insert("some".into(), vec![1.449, -5365.3849, 97194619.117391]);
		val.insert("test".into(), vec![-3917.195, 19461.3849, -365.195759]);
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <OrdMap<String, Vec<f64>> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(
			&mut mem.as_slice(),
		)
		.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_ordmap_empty() {
		let val: OrdMap<String, i32> = OrdMap::new();
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <OrdMap<String, i32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(
			&mut mem.as_slice(),
		)
		.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_ordset() {
		let mut val: OrdSet<String> = OrdSet::new();
		val.insert("one".into());
		val.insert("two".into());
		val.insert("three".into());
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out =
			<OrdSet<String> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_ordset_empty() {
		let val: OrdSet<i32> = OrdSet::new();
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out =
			<OrdSet<i32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_hashmap() {
		let mut val: HashMap<String, Vec<f64>> = HashMap::new();
		val.insert("some".into(), vec![1.449, -5365.3849, 97194619.117391]);
		val.insert("test".into(), vec![-3917.195, 19461.3849, -365.195759]);
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <HashMap<String, Vec<f64>> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(
			&mut mem.as_slice(),
		)
		.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_hashmap_empty() {
		let val: HashMap<String, i32> = HashMap::new();
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out = <HashMap<String, i32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(
			&mut mem.as_slice(),
		)
		.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_hashset() {
		let mut val: HashSet<String> = HashSet::new();
		val.insert("one".into());
		val.insert("two".into());
		val.insert("three".into());
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out =
			<HashSet<String> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}

	#[test]
	fn test_hashset_empty() {
		let val: HashSet<i32> = HashSet::new();
		let mut mem: Vec<u8> = vec![];
		val.serialize_lyxal_revisioned(&mut mem).unwrap();
		let out =
			<HashSet<i32> as DeserializeLyxalRevisioned>::deserialize_lyxal_revisioned(&mut mem.as_slice())
				.unwrap();
		assert_eq!(val, out);
	}
}

