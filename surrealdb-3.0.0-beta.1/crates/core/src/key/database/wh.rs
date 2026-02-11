//! Stores a DEFINE WEBHOOK definition
use std::borrow::Cow;

use anyhow::Result;
use storekey::{BorrowDecode, Encode};

use crate::catalog::{DatabaseId, NamespaceId};
use crate::key::category::{Categorise, Category};
use crate::kvs::{KVKey, impl_kv_key_storekey};
use crate::catalog::WebhookDefinition;

#[derive(Clone, Debug, Eq, PartialEq, PartialOrd, Encode, BorrowDecode)]
pub(crate) struct Wh<'a> {
    __: u8,
    _a: u8,
    pub ns: NamespaceId,
    _b: u8,
    pub db: DatabaseId,
    _c: u8,
    _d: u8,
    _e: u8,
    pub wh: Cow<'a, str>,
}

impl_kv_key_storekey!(Wh<'_> => WebhookDefinition);

#[allow(dead_code)]
pub fn new(ns: NamespaceId, db: DatabaseId, wh: &str) -> Wh<'_> {
    Wh::new(ns, db, wh)
}

#[allow(dead_code)]
pub fn prefix(ns: NamespaceId, db: DatabaseId) -> Result<Vec<u8>> {
    let mut k = super::all::new(ns, db).encode_key()?;
    k.extend_from_slice(b"!wh\x00");
    Ok(k)
}

#[allow(dead_code)]
pub fn suffix(ns: NamespaceId, db: DatabaseId) -> Result<Vec<u8>> {
    let mut k = super::all::new(ns, db).encode_key()?;
    k.extend_from_slice(b"!wh\xff");
    Ok(k)
}

impl Categorise for Wh<'_> {
    fn categorise(&self) -> Category {
        Category::DatabaseWebhook
    }
}

impl<'a> Wh<'a> {
    pub fn new(ns: NamespaceId, db: DatabaseId, wh: &'a str) -> Self {
        Self {
            __: b'/',
            _a: b'*',
            ns,
            _b: b'*',
            db,
            _c: b'!',
            _d: b'w',
            _e: b'h',
            wh: Cow::Borrowed(wh),
        }
    }
}
