pub mod export;

mod api;
mod batch;
mod clock;
mod ds;
mod err;
mod into;
mod key;
mod scanner;
mod threadpool;
mod timestamp;
mod tr;
mod tx;
mod util;

mod indxdb;
mod mem;

// REPARATION: DÃ©claration explicite du module lyxalkv
#[cfg(feature = "kv-lyxalkv")]
pub mod lyxalkv;

#[cfg(test)]
mod tests;

pub(crate) mod cache;
pub(crate) mod index;
pub(crate) mod sequences;
pub(crate) mod slowlog;
pub(crate) mod tasklease;
pub(crate) mod version;

pub use api::Transactable;
pub use clock::SizedClock;
pub use ds::requirements::{TransactionBuilderFactoryRequirements, TransactionBuilderRequirements};
pub use ds::{Datastore, DatastoreFlavor, TransactionBuilder, TransactionBuilderFactory};
pub use err::{Error, Result};
pub use into::IntoBytes;
pub use key::{KVKey, KVValue};
pub(crate) use key::{impl_kv_key_storekey, impl_kv_value_revisioned};
pub use scanner::{Direction, Scanner};
pub use timestamp::{HlcTimestamp, IncTimestamp, Timestamp};
pub use tr::{LockType, TransactionType, Transactor};
pub use tx::Transaction;

pub type Key = Vec<u8>;
pub type Val = Vec<u8>;
pub type Version = u64;