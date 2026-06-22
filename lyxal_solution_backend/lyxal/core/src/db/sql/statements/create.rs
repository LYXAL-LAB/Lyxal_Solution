use lyxal_types::{SqlFormat, ToSql, write_sql};

use crate::utils::fmt::{CoverStmts, Fmt};
use crate::db::sql::{Data, Expr, Literal, Output};

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct CreateStatement {
	// A keyword modifier indicating if we are expecting a single result or several
	pub only: bool,
	// Where we are creating (i.e. table, or record ID)
	#[cfg_attr(feature = "arbitrary", arbitrary(with = crate::db::sql::arbitrary::atleast_one))]
	pub what: Vec<Expr>,
	// The data associated with the record being created
	pub data: Option<Data>,
	//  What the result of the statement should resemble (i.e. Diff or no result etc).
	pub output: Option<Output>,
	// The timeout for the statement
	pub timeout: Expr,
}

impl Default for CreateStatement {
	fn default() -> Self {
		Self {
			only: Default::default(),
			what: Default::default(),
			data: Default::default(),
			output: Default::default(),
			timeout: Expr::Literal(Literal::None),
		}
	}
}

impl ToSql for CreateStatement {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "CREATE");
		if self.only {
			write_sql!(f, fmt, " ONLY");
		}
		write_sql!(f, fmt, " {}", Fmt::comma_separated(self.what.iter().map(CoverStmts)));
		if let Some(ref v) = self.data {
			write_sql!(f, fmt, " {v}");
		}
		if let Some(ref v) = self.output {
			write_sql!(f, fmt, " {v}");
		}
		if !matches!(self.timeout, Expr::Literal(Literal::None)) {
			write_sql!(f, fmt, " TIMEOUT {}", CoverStmts(&self.timeout));
		}
	}
}

impl From<CreateStatement> for crate::db::expr::statements::CreateStatement {
	fn from(v: CreateStatement) -> Self {
		crate::db::expr::statements::CreateStatement {
			only: v.only,
			what: v.what.into_iter().map(From::from).collect(),
			data: v.data.map(Into::into),
			output: v.output.map(Into::into),
			timeout: v.timeout.into(),
		}
	}
}

impl From<crate::db::expr::statements::CreateStatement> for CreateStatement {
	fn from(v: crate::db::expr::statements::CreateStatement) -> Self {
		CreateStatement {
			only: v.only,
			what: v.what.into_iter().map(From::from).collect(),
			data: v.data.map(Into::into),
			output: v.output.map(Into::into),
			timeout: v.timeout.into(),
		}
	}
}
