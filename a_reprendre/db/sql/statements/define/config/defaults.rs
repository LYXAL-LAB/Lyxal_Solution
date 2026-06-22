use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_db::sql::{Expr, Literal};

#[derive(Clone, Debug, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct DefaultConfig {
	pub namespace: Expr,
	pub database: Expr,
}

impl Default for DefaultConfig {
	fn default() -> Self {
		Self {
			namespace: Expr::Literal(Literal::None),
			database: Expr::Literal(Literal::None),
		}
	}
}

impl ToSql for DefaultConfig {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, " DEFAULT");
		write_sql!(f, fmt, " NAMESPACE {}", self.namespace);
		write_sql!(f, fmt, " DATABASE {}", self.database);
	}
}

impl From<DefaultConfig> for crate::lyxal_core_db::expr::statements::define::config::defaults::DefaultConfig {
	fn from(v: DefaultConfig) -> Self {
		crate::lyxal_core_db::expr::statements::define::config::defaults::DefaultConfig {
			namespace: v.namespace.into(),
			database: v.database.into(),
		}
	}
}
impl From<crate::lyxal_core_db::expr::statements::define::config::defaults::DefaultConfig> for DefaultConfig {
	fn from(v: crate::lyxal_core_db::expr::statements::define::config::defaults::DefaultConfig) -> Self {
		DefaultConfig {
			namespace: v.namespace.into(),
			database: v.database.into(),
		}
	}
}
