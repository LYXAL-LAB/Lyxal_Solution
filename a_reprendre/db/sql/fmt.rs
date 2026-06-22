use lyxal_types_core::{SqlFormat, ToSql};
use crate::lyxal_core_utils::fmt::{EscapeKwFreeIdent, EscapeWriter};
use crate::lyxal_core_db::sql;
use crate::lyxal_core_db::syn;

/// Escapes identifiers which might be used in the same place as a keyword.
pub struct EscapeIdent<T>(pub T);
impl<T: AsRef<str>> ToSql for EscapeIdent<T> {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		let s = self.0.as_ref();
		if syn::could_be_reserved_keyword(s) {
			f.push('`');
			EscapeWriter::escape(f, '`', self.0.as_ref());
			f.push('`');
		} else {
			EscapeKwFreeIdent(s).fmt_sql(f, fmt);
		}
	}
}

pub struct CoverStmts<'a>(pub &'a sql::Expr);

impl ToSql for CoverStmts<'_> {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self.0 {
			sql::Expr::Literal(_)
			| sql::Expr::Param(_)
			| sql::Expr::Idiom(_)
			| sql::Expr::Table(_)
			| sql::Expr::Mock(_)
			| sql::Expr::Block(_)
			| sql::Expr::Constant(_)
			| sql::Expr::Prefix {
				..
			}
			| sql::Expr::Postfix {
				..
			}
			| sql::Expr::Binary {
				..
			}
			| sql::Expr::FunctionCall(_)
			| sql::Expr::Closure(_)
			| sql::Expr::Break
			| sql::Expr::Continue
			| sql::Expr::Throw(_) => self.0.fmt_sql(f, fmt),
			sql::Expr::Return(x) => {
				if x.fetch.is_some() {
					f.push('(');
					self.0.fmt_sql(f, fmt);
					f.push(')')
				} else {
					self.0.fmt_sql(f, fmt);
				}
			}

			sql::Expr::IfElse(_)
			| sql::Expr::Select(_)
			| sql::Expr::Create(_)
			| sql::Expr::Update(_)
			| sql::Expr::Upsert(_)
			| sql::Expr::Delete(_)
			| sql::Expr::Relate(_)
			| sql::Expr::Insert(_)
			| sql::Expr::Define(_)
			| sql::Expr::Remove(_)
			| sql::Expr::Rebuild(_)
			| sql::Expr::Alter(_)
			| sql::Expr::Info(_)
			| sql::Expr::Foreach(_)
			| sql::Expr::Let(_)
			| sql::Expr::Sleep(_)
			| sql::Expr::Explain {
				..
			} => {
				f.push('(');
				self.0.fmt_sql(f, fmt);
				f.push(')')
			}
		}
	}
}
