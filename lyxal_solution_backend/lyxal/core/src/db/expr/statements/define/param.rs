use anyhow::{Result, bail};
use reblessive::tree::Stk;

use super::DefineKind;
use crate::db::catalog::providers::{CatalogProvider, DatabaseProvider};
use crate::db::catalog::{ParamDefinition, Permission};
use crate::db::ctx::FrozenContext;
use crate::db::dbs::Options;
use crate::db::doc::CursorDoc;
use crate::error::Error;
use crate::db::expr::{Base, Expr, FlowResultExt as _};
use crate::db::iam::{Action, ResourceKind};
use crate::db::val::Value;

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct DefineParamStatement {
	pub kind: DefineKind,
	pub name: String,
	pub value: Expr,
	pub comment: Expr,
	pub permissions: Permission,
}

impl DefineParamStatement {
	/// Process this type returning a computed simple Value
	#[instrument(level = "trace", name = "DefineParamStatement::compute", skip_all)]
	pub(crate) async fn compute(
		&self,
		stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		doc: Option<&CursorDoc>,
	) -> Result<Value> {
		// Allowed to run?
		opt.is_allowed(Action::Edit, ResourceKind::Parameter, &Base::Db)?;

		let value = stk.run(|stk| self.value.compute(stk, ctx, opt, doc)).await.catch_return()?;

		// Fetch the transaction
		let txn = ctx.tx();

		// Check if the definition exists
		let (ns, db) = ctx.get_ns_db_ids(opt).await?;
		if txn.get_db_param(ns, db, &self.name).await.is_ok() {
			match self.kind {
				DefineKind::Default => {
					if !opt.import {
						bail!(Error::PaAlreadyExists {
							name: self.name.clone(),
						});
					}
				}
				DefineKind::Overwrite => {}
				DefineKind::IfNotExists => return Ok(Value::None),
			}
		}

		let db = {
			let (ns, db) = opt.ns_db()?;
			txn.get_or_add_db(Some(ctx), ns, db).await?
		};

		let comment = stk
			.run(|stk| self.comment.compute(stk, ctx, opt, doc))
			.await
			.catch_return()?
			.cast_to()?;
		// Process the statement
		txn.put_db_param(
			db.namespace_id,
			db.database_id,
			&ParamDefinition {
				value,
				name: self.name.clone(),
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
