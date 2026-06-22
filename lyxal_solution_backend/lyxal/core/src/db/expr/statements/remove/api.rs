use anyhow::Result;
use reblessive::tree::Stk;

use crate::db::catalog::providers::ApiProvider;
use crate::db::ctx::FrozenContext;
use crate::db::dbs::Options;
use crate::db::doc::CursorDoc;
use crate::error::Error;
use crate::db::expr::parameterize::expr_to_ident;
use crate::db::expr::{Base, Expr, Literal, Value};
use crate::db::iam::{Action, ResourceKind};

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct RemoveApiStatement {
	pub name: Expr,
	pub if_exists: bool,
}

impl Default for RemoveApiStatement {
	fn default() -> Self {
		Self {
			name: Expr::Literal(Literal::None),
			if_exists: false,
		}
	}
}

impl RemoveApiStatement {
	/// Process this type returning a computed simple Value
	pub(crate) async fn compute(
		&self,
		stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		doc: Option<&CursorDoc>,
	) -> Result<Value> {
		// Allowed to run?
		opt.is_allowed(Action::Edit, ResourceKind::Api, &Base::Db)?;
		// Compute the name
		let name = expr_to_ident(stk, ctx, opt, doc, &self.name, "api name").await?;
		// Get the transaction
		let txn = ctx.tx();
		// Get the definition
		let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
		// Check if the api exists
		let Some(ap) = txn.get_db_api(ns, db, &name).await? else {
			if self.if_exists {
				return Ok(Value::None);
			} else {
				return Err(Error::ApNotFound {
					value: name,
				}
				.into());
			}
		};

		// Delete the definition
		let name = ap.path.to_string();
		let key = crate::db::key::database::ap::new(ns, db, &name);
		txn.del(&key).await?;
		// Clear the cache
		txn.clear_cache();
		// Ok all good
		Ok(Value::None)
	}
}
