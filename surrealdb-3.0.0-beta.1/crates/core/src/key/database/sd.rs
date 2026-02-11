//! Stores a DEFINE SCHEDULER config definition
use std::borrow::Cow;

use anyhow::Result;
use storekey::{BorrowDecode, Encode};

use crate::catalog::{DatabaseId, NamespaceId};
use crate::key::category::{Categorise, Category};
use crate::kvs::{KVKey, impl_kv_key_storekey};
use crate::catalog::SchedulerDefinition;

#[derive(Clone, Debug, Eq, PartialEq, PartialOrd, Encode, BorrowDecode)]
pub(crate) struct Sd<'a> {
	__: u8,
	_a: u8,
	pub ns: NamespaceId,
	_b: u8,
	pub db: DatabaseId,
	_c: u8,
	_d: u8,
	_e: u8,
	pub sd: Cow<'a, str>,
}

impl_kv_key_storekey!(Sd<'_> => SchedulerDefinition);

#[allow(dead_code)]
pub fn new(ns: NamespaceId, db: DatabaseId, sd: &str) -> Sd<'_> {
	Sd::new(ns, db, sd)
}

#[allow(dead_code)]
pub fn prefix(ns: NamespaceId, db: DatabaseId) -> Result<Vec<u8>> {
	let mut k = super::all::new(ns, db).encode_key()?;
	k.extend_from_slice(b"!sd\x00");
	Ok(k)
}

#[allow(dead_code)]
pub fn suffix(ns: NamespaceId, db: DatabaseId) -> Result<Vec<u8>> {
	let mut k = super::all::new(ns, db).encode_key()?;
	k.extend_from_slice(b"!sd\xff");
	Ok(k)
}

impl Categorise for Sd<'_> {
	fn categorise(&self) -> Category {
		Category::DatabaseScheduler
	}
}

impl<'a> Sd<'a> {
	pub fn new(ns: NamespaceId, db: DatabaseId, sd: &'a str) -> Self {
		Self {
			__: b'/',
			_a: b'*',
			ns,
			_b: b'*',
			db,
			_c: b'!',
			_d: b's',
			_e: b'd',
			sd: Cow::Borrowed(sd),
		}
	}
}

