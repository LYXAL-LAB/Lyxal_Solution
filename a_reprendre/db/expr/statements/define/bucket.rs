use anyhow::{Result, bail};
use reblessive::tree::Stk;

use super::{CursorDoc, DefineKind};
use crate::lyxal_core_db::catalog::providers::BucketProvider;
use crate::lyxal_core_db::catalog::{BucketDefinition, Permission};
use crate::lyxal_core_db::ctx::FrozenContext;
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_error::Error;
use crate::lyxal_core_db::expr::parameterize::expr_to_ident;
use crate::lyxal_core_db::expr::{Base, Expr, FlowResultExt, Literal};
use crate::lyxal_core_db::iam::{Action, ResourceKind};
use crate::lyxal_core_db::val::Value;

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct DefineBucketStatement {
	pub kind: DefineKind,
	pub name: Expr,
	pub backend: Option<Expr>,
	pub permissions: Permission,
	pub readonly: bool,
	pub comment: Expr,
}

impl Default for DefineBucketStatement {
	fn default() -> Self {
		Self {
			kind: DefineKind::Default,
			name: Expr::Literal(Literal::None),
			backend: None,
			permissions: Permission::default(),
			readonly: false,
			comment: Expr::Literal(Literal::None),
		}
	}
}

impl DefineBucketStatement {
	#[instrument(level = "trace", name = "DefineBucketStatement::compute", skip_all)]
	pub(crate) async fn compute(
		&self,
		stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		doc: Option<&CursorDoc>,
	) -> Result<Value> {
		// Allowed to run?
		opt.is_allowed(Action::Edit, ResourceKind::Bucket, &Base::Db)?;
		// Process the name
		let name = expr_to_ident(stk, ctx, opt, doc, &self.name, "bucket name").await?;
		// Fetch the transaction
		let txn = ctx.tx();
		let (ns, db) = ctx.get_ns_db_ids(opt).await?;
		// Check if the definition exists
		if let Some(bucket) = txn.get_db_bucket(ns, db, &name).await? {
			match self.kind {
				DefineKind::Default => {
					if !opt.import {
						bail!(Error::BuAlreadyExists {
							value: bucket.name.clone(),
						});
					}
				}
				DefineKind::Overwrite => {}
				DefineKind::IfNotExists => {
					return Ok(Value::None);
				}
			}
		}
		// Process the backend input
		let backend = if let Some(ref url) = self.backend {
			Some(
				stk.run(|stk| url.compute(stk, ctx, opt, doc))
					.await
					.catch_return()?
					.coerce_to::<String>()?,
			)
		} else {
			None
		};

		// Create and cache a new backend
		if let Some(buckets) = ctx.get_buckets() {
			buckets.new_backend(ns, db, &name, self.readonly, backend.as_deref()).await?;
		} else {
			bail!(Error::BucketUnavailable(name));
		}

		// Process the statement
		let key = crate::lyxal_core_db::key::database::bu::new(ns, db, &name);

		let comment = stk
			.run(|stk| self.comment.compute(stk, ctx, opt, doc))
			.await
			.catch_return()?
			.cast_to()?;

		let ap = BucketDefinition {
			id: None,
			name: name.clone(),
			backend,
			permissions: self.permissions.clone(),
			readonly: self.readonly,
			comment,
		};
		txn.set(&key, &ap, None).await?;
		// Clear the cache
		txn.clear_cache();
		// Ok all good
		Ok(Value::None)
	}
}
