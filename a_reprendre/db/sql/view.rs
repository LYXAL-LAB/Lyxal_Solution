use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_utils::fmt::{EscapeKwFreeIdent, Fmt};
use crate::lyxal_core_db::sql::{Cond, Fields, Groups};
use crate::lyxal_core_db::val::TableName;

#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct View {
	pub expr: Fields,
	pub what: Vec<String>,
	pub cond: Option<Cond>,
	pub group: Option<Groups>,
}

impl ToSql for View {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(
			f,
			fmt,
			"AS SELECT {} FROM {}",
			self.expr,
			Fmt::comma_separated(self.what.iter().map(|x| EscapeKwFreeIdent(x.as_ref())))
		);
		if let Some(ref v) = self.cond {
			write_sql!(f, fmt, " {v}");
		}
		if let Some(ref v) = self.group {
			write_sql!(f, fmt, " {v}");
		}
	}
}

impl From<View> for crate::lyxal_core_db::expr::View {
	fn from(v: View) -> Self {
		crate::lyxal_core_db::expr::View {
			materialize: true,
			expr: v.expr.into(),
			what: v.what.into_iter().map(TableName::new).collect(),
			cond: v.cond.map(Into::into),
			group: v.group.map(Into::into),
		}
	}
}

impl From<crate::lyxal_core_db::expr::View> for View {
	fn from(v: crate::lyxal_core_db::expr::View) -> Self {
		View {
			expr: v.expr.into(),
			what: v.what.into_iter().map(TableName::into_string).collect(),
			cond: v.cond.map(Into::into),
			group: v.group.map(Into::into),
		}
	}
}
