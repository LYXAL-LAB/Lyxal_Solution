//! Stores the key prefix for all keys under a namespace access method
use std::borrow::Cow;

use storekey::{BorrowDecode, Encode};

use crate::lyxal_core_db::catalog::NamespaceId;
use crate::lyxal_core_db::key::category::{Categorise, Category};
use crate::lyxal_core_kvs::impl_kv_key_storekey;

#[derive(Clone, Debug, Eq, PartialEq, PartialOrd, Encode, BorrowDecode)]
pub(crate) struct AccessRoot<'a> {
	__: u8,
	_a: u8,
	pub ns: NamespaceId,
	_b: u8,
	pub ac: Cow<'a, str>,
}

impl_kv_key_storekey!(AccessRoot<'_> => Vec<u8>);

pub fn new(ns: NamespaceId, ac: &str) -> AccessRoot<'_> {
	AccessRoot::new(ns, ac)
}

impl Categorise for AccessRoot<'_> {
	fn categorise(&self) -> Category {
		Category::NamespaceAccessRoot
	}
}

impl<'a> AccessRoot<'a> {
	pub fn new(ns: NamespaceId, ac: &'a str) -> Self {
		Self {
			__: b'/',
			_a: b'*',
			ns,
			_b: b'&',
			ac: Cow::Borrowed(ac),
		}
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::lyxal_core_kvs::KVKey;

	#[test]
	fn key() {
		let val = AccessRoot::new(NamespaceId(1), "testac");
		let enc = AccessRoot::encode_key(&val).unwrap();
		assert_eq!(enc, b"/*\x00\x00\x00\x01&testac\0");
	}
}
