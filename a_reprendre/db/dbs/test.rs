use std::sync::Arc;

use uuid::Uuid;

use crate::lyxal_core_config::cnf::dynamic::DynamicConfiguration;
use crate::lyxal_core_db::ctx::{Context, FrozenContext};
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_db::iam::{Auth, Role};
use crate::lyxal_core_kvs::Datastore;
use crate::lyxal_core_kvs::LockType::*;
use crate::lyxal_core_kvs::TransactionType::*;

pub async fn mock() -> (FrozenContext, Options) {
	let opt = Options::new(Uuid::new_v4(), DynamicConfiguration::default())
		.with_auth(Arc::new(Auth::for_root(Role::Owner)));
	let kvs = Datastore::new("memory").await.unwrap();
	let txn = kvs.transaction(Write, Optimistic).await.unwrap().enclose();
	let mut ctx = Context::default();
	ctx.set_transaction(txn);
	(ctx.freeze(), opt)
}
