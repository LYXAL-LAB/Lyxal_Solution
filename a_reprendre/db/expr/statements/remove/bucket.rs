use anyhow::Result;
use reblessive::tree::Stk;

use crate::lyxal_core_db::catalog::providers::BucketProvider;
use crate::lyxal_core_db::ctx::FrozenContext;
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_db::doc::CursorDoc;
use crate::lyxal_core_error::Error;
use crate::lyxal_core_db::expr::parameterize::expr_to_ident;
use crate::lyxal_core_db::expr::{Base, Expr, Literal, Value};
use crate::lyxal_core_db::iam::{Action, ResourceKind};

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct RemoveBucketStatement {
	pub name: Expr,
	pub if_exists: bool,
}

impl Default for RemoveBucketStatement {
	fn default() -> Self {
		Self {
			name: Expr::Literal(Literal::None),
			if_exists: false,
		}
	}
}

impl RemoveBucketStatement {
	/// Process this type returning a computed simple Value
	pub(crate) async fn compute(
		&self,
		stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		doc: Option<&CursorDoc>,
	) -> Result<Value> {
		// Allowed to run?
		opt.is_allowed(Action::Edit, ResourceKind::Bucket, &Base::Db)?;
		// Compute the name
		let name = expr_to_ident(stk, ctx, opt, doc, &self.name, "bucket name").await?;
		// Get the transaction
		let txn = ctx.tx();
		// Get the definition
		let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
		let Some(bu) = txn.get_db_bucket(ns, db, &name).await? else {
			if self.if_exists {
				return Ok(Value::None);
			} else {
				return Err(Error::BuNotFound {
					name,
				}
				.into());
			}
		};

		// Delete the definition
		let key = crate::lyxal_core_db::key::database::bu::new(ns, db, &bu.name);
		txn.del(&key).await?;
		// Clear the cache
		txn.clear_cache();
		// Ok all good
		Ok(Value::None)
	}
}
