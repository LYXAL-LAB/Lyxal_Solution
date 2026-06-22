use reblessive::tree::Stk;
use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_db::ctx::FrozenContext;
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_db::doc::CursorDoc;
use crate::lyxal_core_db::expr::FlowResult;
use crate::lyxal_core_db::sql::EscapeIdent;
use crate::lyxal_core_db::val::{RecordId, TableName};

pub(crate) mod key;
pub(crate) use key::{RecordIdKeyGen, RecordIdKeyLit};
pub(crate) mod range;
pub(crate) use range::RecordIdKeyRangeLit;

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct RecordIdLit {
	/// Table name
	pub table: TableName,
	pub(crate) key: RecordIdKeyLit,
}

impl RecordIdLit {
	pub(crate) fn is_static(&self) -> bool {
		self.key.is_static()
	}

	pub(crate) async fn compute(
		&self,
		stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		doc: Option<&CursorDoc>,
	) -> FlowResult<RecordId> {
		Ok(RecordId {
			table: self.table.clone(),
			key: self.key.compute(stk, ctx, opt, doc).await?,
		})
	}
}

impl ToSql for RecordIdLit {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		write_sql!(f, sql_fmt, "{}:{}", EscapeIdent(&self.table), self.key)
	}
}
