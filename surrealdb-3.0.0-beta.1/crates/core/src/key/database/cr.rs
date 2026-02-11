//! Stores a DEFINE CREDENTIAL definition
use std::borrow::Cow;

use anyhow::Result;
use storekey::{BorrowDecode, Encode};

use crate::catalog::{DatabaseId, NamespaceId, CredentialDefinition};
use crate::key::category::{Categorise, Category};
use crate::kvs::{KVKey, impl_kv_key_storekey};

#[derive(Clone, Debug, Eq, PartialEq, PartialOrd, Encode, BorrowDecode)]
pub(crate) struct Cr<'a> {
    __: u8,
    _a: u8,
    pub ns: NamespaceId,
    _b: u8,
    pub db: DatabaseId,
    _c: u8,
    _d: u8,
    _e: u8,
    pub cr: Cow<'a, str>,
}

impl_kv_key_storekey!(Cr<'_> => CredentialDefinition);

pub fn new(ns: NamespaceId, db: DatabaseId, cr: &str) -> Cr<'_> {
    Cr::new(ns, db, cr)
}

#[allow(dead_code)]
pub fn prefix(ns: NamespaceId, db: DatabaseId) -> Result<Vec<u8>> {
    let mut k = super::all::new(ns, db).encode_key()?;
    k.extend_from_slice(b"!cr\x00");
    Ok(k)
}

#[allow(dead_code)]
pub fn suffix(ns: NamespaceId, db: DatabaseId) -> Result<Vec<u8>> {
    let mut k = super::all::new(ns, db).encode_key()?;
    k.extend_from_slice(b"!cr\xff");
    Ok(k)
}

impl Categorise for Cr<'_> {
    fn categorise(&self) -> Category {
        Category::DatabaseCredential
    }
}

impl<'a> Cr<'a> {
    pub fn new(ns: NamespaceId, db: DatabaseId, cr: &'a str) -> Self {
        Self {
            __: b'/',
            _a: b'*',
            ns,
            _b: b'*',
            db,
            _c: b'!',
            _d: b'c',
            _e: b'r',
            cr: Cow::Borrowed(cr),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn key() {
        let val = Cr::new(NamespaceId(1), DatabaseId(2), "stripe_api");
        let enc = Cr::encode_key(&val).unwrap();
        assert_eq!(enc, b"/*\x00\x00\x00\x01*\x00\x00\x00\x02!crstripe_api\0");
    }
}
