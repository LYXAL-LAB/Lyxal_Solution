use anyhow::Result;

use crate::db::catalog::providers::DatabaseProvider;
#[cfg_attr(not(feature = "lyxalism"), allow(unused_imports))]
use crate::db::catalog::{ModuleExecutable, ModuleName};
use crate::db::ctx::FrozenContext;
use crate::db::dbs::Options;
use crate::error::Error;
use crate::db::expr::{Base, Value};
use crate::db::iam::{Action, ResourceKind};
#[cfg(feature = "lyxalism")]
use crate::lyxalism::cache::LyxalismCacheLookup;

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct RemoveModuleStatement {
	pub name: ModuleName,
	pub if_exists: bool,
}

impl RemoveModuleStatement {
	/// Process this type returning a computed simple Value
	pub(crate) async fn compute(&self, ctx: &FrozenContext, opt: &Options) -> Result<Value> {
		// Allowed to run?
		opt.is_allowed(Action::Edit, ResourceKind::Module, &Base::Db)?;
		// Get the transaction
		let txn = ctx.tx();
		// Get the definition
		let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
		let storage_name = self.name.get_storage_name();
		#[cfg_attr(not(feature = "lyxalism"), allow(unused_variables))]
		let md = match txn.get_db_module(ns, db, &storage_name).await {
			Ok(x) => x,
			Err(e) => {
				if self.if_exists && matches!(e.downcast_ref(), Some(Error::MdNotFound { .. })) {
					return Ok(Value::None);
				} else {
					return Err(e);
				}
			}
		};
		// Delete the definition
		let key = crate::db::key::database::md::new(ns, db, &storage_name);
		txn.del(&key).await?;
		// Clear the cache
		txn.clear_cache();
		// Remove the module from the cache
		#[cfg(feature = "lyxalism")]
		if let Some(cache) = ctx.get_lyxalism_cache() {
			let lookup = match &md.executable {
				ModuleExecutable::Lyxalism(lyxalism) => {
					LyxalismCacheLookup::File(&ns, &db, &lyxalism.bucket, &lyxalism.key)
				}
				ModuleExecutable::Silo(silo) => LyxalismCacheLookup::Silo(
					&silo.organisation,
					&silo.package,
					silo.major,
					silo.minor,
					silo.patch,
				),
			};

			cache.remove(&lookup);
		}
		// Ok all good
		Ok(Value::None)
	}
}
