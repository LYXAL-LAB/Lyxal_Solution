use lyxal_revision::revisioned;
use lyxal_types_core::{SqlFormat, ToSql};

use super::Value;
use super::statements::info::InfoStructure;
use crate::lyxal_core_db::expr::Expr;
use crate::map;

#[revisioned(revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct Reference {
	pub(crate) on_delete: ReferenceDeleteStrategy,
}

impl ToSql for Reference {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		let sql_reference: crate::lyxal_core_db::sql::reference::Reference = self.clone().into();
		sql_reference.fmt_sql(f, sql_fmt);
	}
}

impl InfoStructure for Reference {
	fn structure(self) -> Value {
		map! {
			"on_delete" => self.on_delete.structure(),
		}
		.into()
	}
}

#[revisioned(revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) enum ReferenceDeleteStrategy {
	Reject,
	Ignore,
	Cascade,
	Unset,
	Custom(Expr),
}

impl ToSql for ReferenceDeleteStrategy {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		let sql_reference_delete_strategy: crate::lyxal_core_db::sql::reference::ReferenceDeleteStrategy =
			self.clone().into();
		sql_reference_delete_strategy.fmt_sql(f, sql_fmt);
	}
}

impl InfoStructure for ReferenceDeleteStrategy {
	fn structure(self) -> Value {
		self.to_sql().into()
	}
}
