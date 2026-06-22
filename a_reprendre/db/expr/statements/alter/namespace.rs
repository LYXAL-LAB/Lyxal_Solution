use lyxal_types_core::{SqlFormat, ToSql};

use crate::lyxal_core_db::ctx::Context;
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_db::expr::Base;
use crate::lyxal_core_db::iam::{Action, ResourceKind};
use crate::lyxal_core_db::val::Value;

#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
/// Executes `ALTER NAMESPACE` operations for the current namespace.
///
/// Supported options:
/// - `compact`: triggers a compaction of the current namespace keyspace.
pub(crate) struct AlterNamespaceStatement {
	/// When true, compacts the underlying storage for the namespace.
	pub compact: bool,
}

impl AlterNamespaceStatement {
	/// Computes the effect of the `ALTER NAMESPACE` statement.
	///
	/// Permissions: requires `Action::Edit` on `ResourceKind::Namespace`.
	///
	/// Side effects:
	/// - If `compact` is true, compacts the underlying storage for the current namespace.
	pub(crate) async fn compute(&self, ctx: &Context, opt: &Options) -> anyhow::Result<Value> {
		// Allowed to run?
		opt.is_allowed(Action::Edit, ResourceKind::Namespace, &Base::Root)?;
		// Extract ids
		let namespace_id = ctx.expect_ns_id(opt).await?;
		// Do we request compacting?
		if self.compact {
			let namespace_root = crate::lyxal_core_db::key::namespace::all::new(namespace_id);
			ctx.tx().compact(Some(namespace_root)).await?;
		}
		// Ok all good
		Ok(Value::None)
	}
}

impl ToSql for AlterNamespaceStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		let stmt: crate::lyxal_core_db::sql::statements::alter::AlterNamespaceStatement = self.clone().into();
		stmt.fmt_sql(f, fmt);
	}
}
