#![cfg(any(
	feature = "kv-mem",
	feature = "kv-indxdb",
	feature = "kv-lyxalkv",
))]

use std::future::Future;
use std::sync::Arc;

use uuid::Uuid;

use super::Datastore;
use crate::kvs::clock::SizedClock;

macro_rules! include_tests {
	($new_ds:ident => $($name:ident),* $(,)?) => {
		$(
			super::$name::define_tests!($new_ds);
		)*
	};
}

mod multireader;
mod multiwriter_different_keys;
mod multiwriter_same_keys_conflict;
mod raw;
mod reverse_iterator;
mod snapshot;

#[derive(Clone, Debug)]
pub(crate) enum Kvs {
	#[cfg_attr(not(feature = "kv-mem"), expect(dead_code))]
	Mem,
	#[cfg_attr(not(feature = "kv-lyxalkv"), expect(dead_code))]
	LyxalKV,
}

// This type is unused when no store is enabled.
#[cfg_attr(not(test), expect(dead_code))]
type ClockType = Arc<SizedClock>;

trait CreateDs {
	async fn create_ds(&self, id: Uuid, ty: ClockType) -> (Datastore, Kvs);
}

impl<F, Fut> CreateDs for F
where
	F: Fn(Uuid, ClockType) -> Fut,
	Fut: Future<Output = (Datastore, Kvs)>,
{
	async fn create_ds(&self, id: Uuid, ty: ClockType) -> (Datastore, Kvs) {
		(self)(id, ty).await
	}
}

#[cfg(feature = "kv-mem")]
mod mem {
	use tokio_util::sync::CancellationToken;
	use uuid::Uuid;

	use super::{ClockType, Kvs};
	use crate::CommunityComposer;
	use crate::kvs::Datastore;

	async fn new_ds(id: Uuid, clock: ClockType) -> (Datastore, Kvs) {
		// Use a memory datastore instance
		let path = "memory";
		// Setup the in-memory datastore
		let ds = Datastore::new_with_clock(
			CommunityComposer(),
			path,
			Some(clock),
			CancellationToken::new(),
		)
		.await
		.unwrap()
		.with_node_id(id);
		// Return the datastore
		(ds, Kvs::Mem)
	}

	include_tests!(new_ds =>
		raw,
		snapshot,
		multireader,
		multiwriter_different_keys,
		multiwriter_same_keys_conflict,
		reverse_iterator,
	);
}

#[cfg(feature = "kv-lyxalkv")]
mod lyxalkv {
	use temp_dir::TempDir;
	use tokio_util::sync::CancellationToken;
	use uuid::Uuid;

	use super::{ClockType, Kvs};
	use crate::CommunityComposer;
	use crate::kvs::Datastore;

	async fn new_ds(id: Uuid, clock: ClockType) -> (Datastore, Kvs) {
		// Setup the temporary data storage path
		let path = TempDir::new().unwrap().path().to_string_lossy().to_string();
		let path = format!("lyxalkv:{path}");
		// Setup the LyxalKV datastore
		let ds = Datastore::new_with_clock(
			CommunityComposer(),
			&path,
			Some(clock),
			CancellationToken::new(),
		)
		.await
		.unwrap()
		.with_node_id(id);
		// Return the datastore
		(ds, Kvs::LyxalKV)
	}

	include_tests!(new_ds =>
		raw,
		snapshot,
		multireader,
		multiwriter_different_keys,
		multiwriter_same_keys_conflict,
		reverse_iterator,
	);
}
