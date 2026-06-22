use anyhow::Result;

use crate::db::ctx::FrozenContext;
use crate::db::dbs::Options;
use crate::db::doc::CursorDoc;
use crate::db::expr::{Base, Value};
use crate::db::iam::{Action, ResourceKind};
use crate::db::val::{Datetime, TableName};

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub enum ShowSince {
	Timestamp(Datetime),
	Versionstamp(u64),
}

/// A SHOW CHANGES statement for displaying changes made to a table or database.

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct ShowStatement {
	pub table: Option<TableName>,
	pub since: ShowSince,
	pub limit: Option<u32>,
}

impl ShowStatement {
	/// Process this type returning a computed simple Value
	#[instrument(level = "trace", name = "ShowStatement::compute", skip_all)]
	pub(crate) async fn compute(
		&self,
		ctx: &FrozenContext,
		opt: &Options,
		_doc: Option<&CursorDoc>,
	) -> Result<Value> {
		// Allowed to run?
		opt.is_allowed(Action::View, ResourceKind::Table, &Base::Db)?;
		// Get the transaction
		let txn = ctx.tx();
		// Process the show query
		let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
		let r = crate::db::cf::read(&txn, ns, db, self.table.as_ref(), self.since.clone(), self.limit)
			.await?;
		// Return the changes
		let a: Vec<Value> = r.iter().cloned().map(|x| x.into_value()).collect();
		Ok(a.into())
	}
}
