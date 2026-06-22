use anyhow::Result;
use reblessive::tree::Stk;
use crate::lyxal_core_error::Error;
use crate::lyxal_core_db::iam::Action;
use crate::lyxal_core_db::iam::ResourceKind;
use crate::lyxal_core_db::sql::statements::remove::RemoveConnectorStatement;
use crate::lyxal_core_db::val::Value;
use crate::lyxal_core_db::ctx::FrozenContext;
use crate::lyxal_core_db::dbs::Options;

impl RemoveConnectorStatement {
	pub(crate) async fn compute(
		&self,
		_stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
	) -> Result<Value> {
		// Allowed to edit the database?
		opt.is_allowed(Action::Edit, ResourceKind::Connector, &self.name.clone().into())?;
		// Get the transaction
		let txn = ctx.tx();
		// Claim the database and namespace
		let ns = opt.ns()?;
		let db = opt.db()?;
		// Delete the connector
		txn.del_db_connector(ns, db, &self.name).await?;
		// Return none
		Ok(Value::None)
	}
}
