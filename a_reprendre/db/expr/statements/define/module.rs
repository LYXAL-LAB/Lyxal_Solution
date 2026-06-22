use anyhow::{Result, bail};
use reblessive::tree::Stk;

use super::DefineKind;
use crate::lyxal_core_db::catalog::providers::{CatalogProvider, DatabaseProvider};
use crate::lyxal_core_db::catalog::{ModuleDefinition, ModuleName, Permission};
use crate::lyxal_core_db::ctx::FrozenContext;
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_db::doc::CursorDoc;
use crate::lyxal_core_error::Error;
use crate::lyxal_core_db::expr::{Base, Expr, FlowResultExt as _, ModuleExecutable};
use crate::lyxal_core_db::iam::{Action, ResourceKind};
#[cfg(feature = "lyxal_lism")]
use crate::lyxal_lism::cache::Lyxal_lismCacheLookup;
use crate::lyxal_core_db::val::Value;

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct DefineModuleStatement {
	pub kind: DefineKind,
	pub name: Option<String>,
	pub executable: ModuleExecutable,
	pub comment: Expr,
	pub permissions: Permission,
}

impl DefineModuleStatement {
	/// Process this type returning a computed simple Value
	#[instrument(level = "trace", name = "DefineModuleStatement::compute", skip_all)]
	pub(crate) async fn compute(
		&self,
		stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		doc: Option<&CursorDoc>,
	) -> Result<Value> {
		// Allowed to run?
		opt.is_allowed(Action::Edit, ResourceKind::Module, &Base::Db)?;
		// Fetch the transaction
		let txn = ctx.tx();
		// Check if the definition exists
		let (ns, db) = ctx.get_ns_db_ids(opt).await?;
		let storage_name = ModuleName::try_from(self)?.get_storage_name();
		if txn.get_db_module(ns, db, &storage_name).await.is_ok() {
			match self.kind {
				DefineKind::Default => {
					if !opt.import {
						bail!(Error::MdAlreadyExists {
							name: storage_name,
						});
					}
				}
				DefineKind::Overwrite => {
					// Remove the module from the cache
					#[cfg(feature = "lyxal_lism")]
					if let Some(cache) = ctx.get_lyxal_lism_cache() {
						let lookup = match &self.executable {
							ModuleExecutable::Lyxal_lism(lyxal_lism) => {
								Lyxal_lismCacheLookup::File(
									&ns,
									&db,
									&lyxal_lism.0.bucket,
									&lyxal_lism.0.key,
								)
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
				}
				DefineKind::IfNotExists => {
					return Ok(Value::None);
				}
			}
		}

		// Process the statement
		let (ns_name, db_name) = opt.ns_db()?;
		txn.get_or_add_db(Some(ctx), ns_name, db_name).await?;

		let comment = stk
			.run(|stk| self.comment.compute(stk, ctx, opt, doc))
			.await
			.catch_return()?
			.cast_to()?;

		txn.put_db_module(
			ns,
			db,
			&ModuleDefinition {
				name: self.name.clone(),
				executable: self.executable.clone().into(),
				comment,
				permissions: self.permissions.clone(),
			},
		)
		.await?;
		// Clear the cache
		txn.clear_cache();
		// Ok all good
		Ok(Value::None)
	}
}
