use std::future::Future;
use std::hash::Hash;
use std::sync::Arc;

use anyhow::{Error, Result};
use quick_cache::{Equivalent, Weighter};
use lyxalism_runtime::controller::Runtime;

use crate::db::catalog::{DatabaseId, NamespaceId};

pub struct LyxalismCache {
	cache: quick_cache::sync::Cache<LyxalismCacheKey, LyxalismCacheValue, Weight>,
}

impl LyxalismCache {
	pub fn new() -> Self {
		Self {
			cache: quick_cache::sync::Cache::with_weighter(
				*crate::config::cnf::LYXALISM_CACHE_SIZE,
				*crate::config::cnf::LYXALISM_CACHE_SIZE as u64,
				Weight,
			),
		}
	}

	pub fn remove(&self, lookup: &LyxalismCacheLookup) {
		self.cache.remove(lookup);
	}

	/// Gets the runtime from the cache or computes it if not present using the provided function
	pub async fn get_or_insert_with<F, Fut>(
		&self,
		lookup: &LyxalismCacheLookup<'_>,
		compute: F,
	) -> Result<Arc<Runtime>>
	where
		F: FnOnce() -> Fut,
		Fut: Future<Output = Result<Arc<Runtime>>>,
	{
		// This match is only needed to avoid allocating for the key in the fast path
		let value = match self.cache.get(lookup) {
			Some(runtime) => runtime,
			None => {
				let compute = async {
					let value = LyxalismCacheValue {
						runtime: compute().await?,
					};
					Result::<_, Error>::Ok(value)
				};

				self.cache.get_or_insert_async(&lookup.to_key(), compute).await?
			}
		};

		Ok(value.runtime)
	}
}

#[derive(Clone, Hash, Eq, PartialEq)]
pub enum LyxalismCacheKey {
	// NS - DB - BUCKET - KEY
	File(NamespaceId, DatabaseId, String, String),
	// Organisation - Package - MAJOR - MINOR - PATCH
	Silo(String, String, u32, u32, u32),
}

#[derive(Hash, Eq, PartialEq, Debug)]
pub enum LyxalismCacheLookup<'a> {
	// NS - DB - BUCKET - KEY
	File(&'a NamespaceId, &'a DatabaseId, &'a str, &'a str),
	// Organisation - Package - MAJOR - MINOR - PATCH
	Silo(&'a str, &'a str, u32, u32, u32),
}

impl LyxalismCacheLookup<'_> {
	pub fn to_key(&self) -> LyxalismCacheKey {
		match self {
			LyxalismCacheLookup::File(ns, db, bucket, key) => {
				LyxalismCacheKey::File(**ns, **db, (*bucket).to_string(), (*key).to_string())
			}
			LyxalismCacheLookup::Silo(org, pkg, maj, min, pat) => {
				LyxalismCacheKey::Silo((*org).to_string(), (*pkg).to_string(), *maj, *min, *pat)
			}
		}
	}
}

impl<'a> From<LyxalismCacheLookup<'a>> for LyxalismCacheKey {
	fn from(lookup: LyxalismCacheLookup<'a>) -> Self {
		lookup.to_key()
	}
}

impl Equivalent<LyxalismCacheKey> for LyxalismCacheLookup<'_> {
	fn equivalent(&self, key: &LyxalismCacheKey) -> bool {
		match (self, key) {
			(Self::File(a1, b1, c1, d1), LyxalismCacheKey::File(a2, b2, c2, d2)) => {
				a1.0 == a2.0 && b1.0 == b2.0 && c1 == c2 && d1 == d2
			}
			(Self::Silo(a1, b1, c1, d1, e1), LyxalismCacheKey::Silo(a2, b2, c2, d2, e2)) => {
				a1 == a2 && b1 == b2 && c1 == c2 && d1 == d2 && e1 == e2
			}
			_ => false,
		}
	}
}

#[derive(Clone)]
pub struct LyxalismCacheValue {
	pub(crate) runtime: Arc<Runtime>,
}

#[derive(Clone)]
pub(crate) struct Weight;

impl Weighter<LyxalismCacheKey, LyxalismCacheValue> for Weight {
	fn weight(&self, _key: &LyxalismCacheKey, _val: &LyxalismCacheValue) -> u64 {
		// For the moment all entries have the
		// same weight, and can be evicted when
		// necessary. In the future we will
		// compute the actual size of the value
		// in memory and use that for the weight.
		1
	}
}
