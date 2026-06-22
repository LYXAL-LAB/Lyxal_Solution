use lyxal_types_core::{SqlFormat, ToSql};

use crate::lyxal_core_db::ctx::Context;
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_db::expr::Base;
use crate::lyxal_core_db::iam::{Action, ResourceKind};
use crate::lyxal_core_db::val::Value;

#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
/// Executes `ALTER DATABASE` operations.
///
/// Supported options:
/// - `compact`: triggers a compaction of the current database keyspace.
pub(crate) struct AlterDatabaseStatement {
	pub compact: bool,
}

impl AlterDatabaseStatement {
	/// Computes the effect of the `ALTER DATABASE` statement.
	///
	/// Permissions: requires `Action::Edit` on `ResourceKind::Database`.
	///
	/// Side effects:
	/// - If `compact` is true, compacts the underlying storage for the current namespace+database.
	pub(crate) async fn compute(&self, ctx: &Context, opt: &Options) -> anyhow::Result<Value> {
		// Allowed to run?
		opt.is_allowed(Action::Edit, ResourceKind::Database, &Base::Ns)?;
		// Extract ids
		let (namespace_id, database_id) = ctx.expect_ns_db_ids(opt).await?;
		// Do we request compacting?
		if self.compact {
			let database_root = crate::lyxal_core_db::key::database::all::new(namespace_id, database_id);
			ctx.tx().compact(Some(database_root)).await?;
		}
		// Ok all good
		Ok(Value::None)
	}
}

impl ToSql for AlterDatabaseStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		let stmt: crate::lyxal_core_db::sql::statements::alter::AlterDatabaseStatement = self.clone().into();
		stmt.fmt_sql(f, fmt);
	}
}
