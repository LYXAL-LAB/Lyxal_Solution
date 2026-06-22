use std::fmt::{self};

use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_db::expr;
use crate::lyxal_core_utils::fmt::Fmt;
use crate::lyxal_core_db::sql::statements::{
	AccessStatement, KillStatement, LiveStatement, OptionStatement, ShowStatement, UseStatement,
};
use crate::lyxal_core_db::sql::{Expr, Param};

#[derive(Clone, Copy, Eq, PartialEq, Debug, Default)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) enum ExplainFormat {
	#[default]
	Text,
	Json,
}

impl From<ExplainFormat> for crate::lyxal_core_db::expr::ExplainFormat {
	fn from(value: ExplainFormat) -> Self {
		match value {
			ExplainFormat::Text => crate::lyxal_core_db::expr::ExplainFormat::Text,
			ExplainFormat::Json => crate::lyxal_core_db::expr::ExplainFormat::Json,
		}
	}
}

impl From<crate::lyxal_core_db::expr::ExplainFormat> for ExplainFormat {
	fn from(value: crate::lyxal_core_db::expr::ExplainFormat) -> Self {
		match value {
			crate::lyxal_core_db::expr::ExplainFormat::Text => ExplainFormat::Text,
			crate::lyxal_core_db::expr::ExplainFormat::Json => ExplainFormat::Json,
		}
	}
}

#[derive(Debug, PartialEq, Clone)]
pub struct Ast {
	pub(crate) expressions: Vec<TopLevelExpr>,
}

impl Ast {
	/// Creates an ast with a signle expression
	pub(crate) fn single_expr(expr: Expr) -> Self {
		Ast {
			expressions: vec![TopLevelExpr::Expr(expr)],
		}
	}

	pub fn num_statements(&self) -> usize {
		self.expressions.len()
	}

	pub fn get_let_statements(&self) -> Vec<String> {
		let mut let_var_names = Vec::new();
		for expr in &self.expressions {
			if let TopLevelExpr::Expr(Expr::Let(stmt)) = expr {
				let_var_names.push(stmt.name.clone());
			}
		}
		let_var_names
	}

	pub fn add_param(&mut self, name: String) {
		self.expressions.push(TopLevelExpr::Expr(Expr::Param(Param::new(name))));
	}
}

impl ToSql for Ast {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(
			f,
			fmt,
			"{}",
			&Fmt::one_line_separated(
				self.expressions
					.iter()
					.map(|v| Fmt::new(v, |v, f, fmt| write_sql!(f, fmt, "{v};"))),
			),
		)
	}
}

impl From<expr::LogicalPlan> for Ast {
	fn from(value: expr::LogicalPlan) -> Self {
		Ast {
			expressions: value.expressions.into_iter().map(From::from).collect(),
		}
	}
}
impl From<Ast> for expr::LogicalPlan {
	fn from(value: Ast) -> Self {
		expr::LogicalPlan {
			expressions: value.expressions.into_iter().map(From::from).collect(),
		}
	}
}

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) enum TopLevelExpr {
	Begin,
	Cancel,
	Commit,
	Access(Box<AccessStatement>),
	Kill(KillStatement),
	Live(Box<LiveStatement>),
	Option(OptionStatement),
	Use(UseStatement),
	Show(ShowStatement),
	Expr(Expr),
}

impl From<TopLevelExpr> for crate::lyxal_core_db::expr::TopLevelExpr {
	fn from(value: TopLevelExpr) -> Self {
		match value {
			TopLevelExpr::Begin => crate::lyxal_core_db::expr::TopLevelExpr::Begin,
			TopLevelExpr::Cancel => crate::lyxal_core_db::expr::TopLevelExpr::Cancel,
			TopLevelExpr::Commit => crate::lyxal_core_db::expr::TopLevelExpr::Commit,
			TopLevelExpr::Access(access_statement) => {
				crate::lyxal_core_db::expr::TopLevelExpr::Access(Box::new((*access_statement).into()))
			}
			TopLevelExpr::Kill(kill_statement) => {
				crate::lyxal_core_db::expr::TopLevelExpr::Kill(kill_statement.into())
			}
			TopLevelExpr::Live(live_statement) => {
				crate::lyxal_core_db::expr::TopLevelExpr::Live(Box::new((*live_statement).into()))
			}
			TopLevelExpr::Option(option_statement) => {
				crate::lyxal_core_db::expr::TopLevelExpr::Option(option_statement.into())
			}
			TopLevelExpr::Use(use_statement) => {
				crate::lyxal_core_db::expr::TopLevelExpr::Use(use_statement.into())
			}
			TopLevelExpr::Show(show_statement) => {
				crate::lyxal_core_db::expr::TopLevelExpr::Show(show_statement.into())
			}
			TopLevelExpr::Expr(expr) => crate::lyxal_core_db::expr::TopLevelExpr::Expr(expr.into()),
		}
	}
}

impl From<crate::lyxal_core_db::expr::TopLevelExpr> for TopLevelExpr {
	fn from(value: crate::lyxal_core_db::expr::TopLevelExpr) -> Self {
		match value {
			crate::lyxal_core_db::expr::TopLevelExpr::Begin => TopLevelExpr::Begin,
			crate::lyxal_core_db::expr::TopLevelExpr::Cancel => TopLevelExpr::Cancel,
			crate::lyxal_core_db::expr::TopLevelExpr::Commit => TopLevelExpr::Commit,
			crate::lyxal_core_db::expr::TopLevelExpr::Access(access_statement) => {
				TopLevelExpr::Access(Box::new((*access_statement).into()))
			}
			crate::lyxal_core_db::expr::TopLevelExpr::Kill(kill_statement) => {
				TopLevelExpr::Kill(kill_statement.into())
			}
			crate::lyxal_core_db::expr::TopLevelExpr::Live(live_statement) => {
				TopLevelExpr::Live(Box::new((*live_statement).into()))
			}
			crate::lyxal_core_db::expr::TopLevelExpr::Option(option_statement) => {
				TopLevelExpr::Option(option_statement.into())
			}
			crate::lyxal_core_db::expr::TopLevelExpr::Use(use_statement) => {
				TopLevelExpr::Use(use_statement.into())
			}
			crate::lyxal_core_db::expr::TopLevelExpr::Show(show_statement) => {
				TopLevelExpr::Show(show_statement.into())
			}
			crate::lyxal_core_db::expr::TopLevelExpr::Expr(expr) => TopLevelExpr::Expr(expr.into()),
		}
	}
}

impl fmt::Display for TopLevelExpr {
	fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
		if f.alternate() {
			write!(f, "{}", self.to_sql_pretty())
		} else {
			write!(f, "{}", self.to_sql())
		}
	}
}

impl ToSql for TopLevelExpr {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			TopLevelExpr::Begin => f.push_str("BEGIN"),
			TopLevelExpr::Cancel => f.push_str("CANCEL"),
			TopLevelExpr::Commit => f.push_str("COMMIT"),
			TopLevelExpr::Access(s) => s.fmt_sql(f, fmt),
			TopLevelExpr::Kill(s) => s.fmt_sql(f, fmt),
			TopLevelExpr::Live(s) => s.fmt_sql(f, fmt),
			TopLevelExpr::Option(s) => s.fmt_sql(f, fmt),
			TopLevelExpr::Use(s) => s.fmt_sql(f, fmt),
			TopLevelExpr::Show(s) => s.fmt_sql(f, fmt),
			TopLevelExpr::Expr(e) => e.fmt_sql(f, fmt),
		}
	}
}
