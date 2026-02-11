use std::borrow::Cow;
use anyhow::Result;
use storekey::{BorrowDecode, Encode};
use crate::catalog::{DatabaseId, NamespaceId};
use crate::key::category::{Categorise, Category};
use crate::kvs::{KVKey, impl_kv_key_storekey};

#[derive(Clone, Debug, Eq, PartialEq, PartialOrd, Encode, BorrowDecode)]
pub(crate) struct Sv<'a> {
	__: u8,
	_a: u8,
	pub ns: NamespaceId,
	_b: u8,
	pub db: DatabaseId,
	_c: u8,
	_d: u8,
	_e: u8,
	pub sv: Cow<'a, str>,
}

impl_kv_key_storekey!(Sv<'_> => u64);

pub fn new(ns: NamespaceId, db: DatabaseId, sv: &str) -> Sv<'_> {
	Sv {
		__: b'/',
		_a: b'*',
		ns,
		_b: b'*',
		db,
		_c: b'!',
		_d: b's',
		_e: b'v',
		sv: Cow::Borrowed(sv),
	}
}

#[allow(dead_code)]
pub fn prefix(ns: NamespaceId, db: DatabaseId) -> Result<Vec<u8>> {
	let mut k = super::all::new(ns, db).encode_key()?;
	k.extend_from_slice(b"!sv\x00");
	Ok(k)
}

#[allow(dead_code)]
pub fn suffix(ns: NamespaceId, db: DatabaseId) -> Result<Vec<u8>> {
	let mut k = super::all::new(ns, db).encode_key()?;
	k.extend_from_slice(b"!sv\xff");
	Ok(k)
}

impl Categorise for Sv<'_> {
	fn categorise(&self) -> Category {
		Category::DatabaseScheduler
	}
}

