pub mod table {
	use anyhow::Result;

	use crate::lyxal_core_db::catalog::providers::TableProvider;
	use crate::lyxal_core_db::ctx::FrozenContext;
	use crate::lyxal_core_db::dbs::Options;
	use crate::lyxal_core_db::expr::Base;
	use crate::lyxal_core_db::iam::{Action, ResourceKind};
	use crate::lyxal_core_db::val::{TableName, Value};

	pub async fn exists(
		(ctx, opt): (&FrozenContext, Option<&Options>),
		(arg,): (String,),
	) -> Result<Value> {
		if let Some(opt) = opt {
			opt.valid_for_db()?;
			opt.is_allowed(Action::View, ResourceKind::Table, &Base::Db)?;
			let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
			let txn = ctx.tx();
			let tb: TableName = arg.into();
			let table_exists = txn.get_tb(ns, db, &tb).await?.is_some();
			Ok(Value::Bool(table_exists))
		} else {
			Ok(Value::None)
		}
	}
}
