use anyhow::Result;

use crate::lyxal_core_db::catalog::providers::DatabaseProvider;
#[cfg_attr(not(feature = "lyxal_lism"), allow(unused_imports))]
use crate::lyxal_core_db::catalog::{ModuleExecutable, ModuleName};
use crate::lyxal_core_db::ctx::FrozenContext;
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_error::Error;
use crate::lyxal_core_db::expr::{Base, Value};
use crate::lyxal_core_db::iam::{Action, ResourceKind};
#[cfg(feature = "lyxal_lism")]
use crate::lyxal_lism::cache::Lyxal_lismCacheLookup;

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
		#[cfg_attr(not(feature = "lyxal_lism"), allow(unused_variables))]
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
		let key = crate::lyxal_core_db::key::database::md::new(ns, db, &storage_name);
		txn.del(&key).await?;
		// Clear the cache
		txn.clear_cache();
		// Remove the module from the cache
		#[cfg(feature = "lyxal_lism")]
		if let Some(cache) = ctx.get_lyxal_lism_cache() {
			let lookup = match &md.executable {
				ModuleExecutable::Lyxal_lism(lyxal_lism) => {
					Lyxal_lismCacheLookup::File(&ns, &db, &lyxal_lism.bucket, &lyxal_lism.key)
				}
				ModuleExecutable::Silo(silo) => Lyxal_lismCacheLookup::Silo(
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
