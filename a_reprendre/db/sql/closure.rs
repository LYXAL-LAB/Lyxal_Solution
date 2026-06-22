use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::{Expr, Kind, Param};

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Closure {
	pub args: Vec<(Param, Kind)>,
	pub returns: Option<Kind>,
	pub body: Expr,
}

impl ToSql for Closure {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "|");
		for (i, (name, kind)) in self.args.iter().enumerate() {
			if i > 0 {
				write_sql!(f, fmt, ", ");
			}
			write_sql!(f, fmt, "{name}: ");
			match kind {
				k @ Kind::Either(_) => write_sql!(f, fmt, "<{}>", k),
				k => write_sql!(f, fmt, "{}", k),
			}
		}
		write_sql!(f, fmt, "|");
		if let Some(returns) = &self.returns {
			write_sql!(f, fmt, " -> {returns}");
		}
		//  To avoid for example || ->? where ->? is a graph from failing to parse because the
		//  parser expects a kind after ->
		if self.body.has_left_idiom() {
			write_sql!(f, fmt, " ({})", &self.body)
		} else {
			write_sql!(f, fmt, " {}", CoverStmts(&self.body))
		}
	}
}

impl From<Closure> for crate::lyxal_core_db::expr::ClosureExpr {
	fn from(v: Closure) -> Self {
		Self {
			args: v.args.into_iter().map(|(i, k)| (i.into(), k.into())).collect(),
			returns: v.returns.map(Into::into),
			body: v.body.into(),
		}
	}
}

impl From<crate::lyxal_core_db::expr::ClosureExpr> for Closure {
	fn from(v: crate::lyxal_core_db::expr::ClosureExpr) -> Self {
		Self {
			args: v.args.into_iter().map(|(i, k)| (i.into(), k.into())).collect(),
			returns: v.returns.map(Into::into),
			body: v.body.into(),
		}
	}
}
