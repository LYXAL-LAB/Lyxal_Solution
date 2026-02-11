#![cfg(feature = "geo")]

use super::super::Error;
use super::super::{DeserializeLyxalRevisioned, LyxalRevisioned, SerializeLyxalRevisioned};
use geo::{Coord, LineString, MultiLineString, MultiPoint, MultiPolygon, Point, Polygon};

impl SerializeLyxalRevisioned for Coord {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.x.serialize_lyxal_revisioned(writer)?;
		self.y.serialize_lyxal_revisioned(writer)
	}
}

impl DeserializeLyxalRevisioned for Coord {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		let x = f64::deserialize_lyxal_revisioned(reader)?;
		let y = f64::deserialize_lyxal_revisioned(reader)?;
		Ok(Self {
			x,
			y,
		})
	}
}

impl LyxalRevisioned for Coord {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

impl SerializeLyxalRevisioned for Point {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.0.serialize_lyxal_revisioned(writer)
	}
}

impl DeserializeLyxalRevisioned for Point {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		Ok(Self(DeserializeLyxalRevisioned::deserialize_lyxal_revisioned(reader)?))
	}
}

impl LyxalRevisioned for Point {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

impl SerializeLyxalRevisioned for LineString {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.0.serialize_lyxal_revisioned(writer)
	}
}

impl DeserializeLyxalRevisioned for LineString {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		Ok(Self(DeserializeLyxalRevisioned::deserialize_lyxal_revisioned(reader)?))
	}
}

impl LyxalRevisioned for LineString {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

impl SerializeLyxalRevisioned for Polygon {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.exterior().serialize_lyxal_revisioned(writer)?;
		self.interiors().len().serialize_lyxal_revisioned(writer)?;
		for interior in self.interiors() {
			interior.serialize_lyxal_revisioned(writer)?;
		}
		Ok(())
	}
}

impl DeserializeLyxalRevisioned for Polygon {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		Ok(Self::new(
			DeserializeLyxalRevisioned::deserialize_lyxal_revisioned(reader)?,
			DeserializeLyxalRevisioned::deserialize_lyxal_revisioned(reader)?,
		))
	}
}

impl LyxalRevisioned for Polygon {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

impl SerializeLyxalRevisioned for MultiPoint {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.0.serialize_lyxal_revisioned(writer)
	}
}

impl DeserializeLyxalRevisioned for MultiPoint {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		Ok(Self(DeserializeLyxalRevisioned::deserialize_lyxal_revisioned(reader)?))
	}
}

impl LyxalRevisioned for MultiPoint {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

impl SerializeLyxalRevisioned for MultiLineString {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.0.serialize_lyxal_revisioned(writer)
	}
}

impl DeserializeLyxalRevisioned for MultiLineString {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		Ok(Self(DeserializeLyxalRevisioned::deserialize_lyxal_revisioned(reader)?))
	}
}

impl LyxalRevisioned for MultiLineString {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

impl SerializeLyxalRevisioned for MultiPolygon {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(&self, writer: &mut W) -> Result<(), Error> {
		self.0.serialize_lyxal_revisioned(writer)
	}
}

impl DeserializeLyxalRevisioned for MultiPolygon {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, Error> {
		Ok(Self(DeserializeLyxalRevisioned::deserialize_lyxal_revisioned(reader)?))
	}
}

impl LyxalRevisioned for MultiPolygon {
	#[inline]
	fn lyxal_revision() -> u16 {
		1
	}
}

#[cfg(test)]
mod test {
	use std::cell::Cell;

	use super::*;

	use crate::implementations::assert_bincode_compat;

	pub struct Rng(pub Cell<u64>);

	impl Rng {
		pub fn next(&self) -> u64 {
			let mut x = self.0.get();
			x ^= x << 13;
			x ^= x >> 7;
			x ^= x << 17;
			self.0.set(x);
			x
		}

		pub fn next_f64(&self) -> f64 {
			f64::from_bits(self.next())
		}

		pub fn next_point(&self) -> Point {
			Point::new(self.next_f64(), self.next_f64())
		}

		pub fn next_points(&self, len: usize) -> Vec<Point> {
			(0..len).map(|_| self.next_point()).collect()
		}

		pub fn next_coords(&self, len: usize) -> Vec<Coord> {
			(0..len).map(|_| self.next_point().0).collect()
		}
	}

	#[test]
	fn compat() {
		let rng = Rng(Cell::new(0x1fb931de31));

		let point_a = rng.next_point();
		let point_b = rng.next_point();
		assert_bincode_compat(&point_a);
		assert_bincode_compat(&point_b);

		let line_string = LineString(rng.next_coords(10));
		assert_bincode_compat(&line_string);

		let create_multi_line =
			|| (0..10).map(|_| LineString(rng.next_coords(10))).collect::<Vec<_>>();

		let create_polygon = || Polygon::new(LineString(rng.next_coords(10)), create_multi_line());

		let polygon = create_polygon();
		assert_bincode_compat(&polygon);

		let multi_point = MultiPoint(rng.next_points(10));
		assert_bincode_compat(&multi_point);

		let multi_line = MultiLineString(create_multi_line());
		assert_bincode_compat(&multi_line);

		let multi_polygon = MultiPolygon((0..10).map(|_| create_polygon()).collect());
		assert_bincode_compat(&multi_polygon);
	}
}

