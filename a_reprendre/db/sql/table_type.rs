use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_utils::fmt::EscapeKwFreeIdent;

/// The type of records stored by a table
#[derive(Debug, Default, Clone, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum TableType {
	#[default]
	Any,
	Normal,
	Relation(Relation),
}

impl ToSql for TableType {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		match self {
			TableType::Normal => {
				write_sql!(f, sql_fmt, " NORMAL");
			}
			TableType::Relation(rel) => {
				write_sql!(f, sql_fmt, " RELATION");
				if !rel.from.is_empty() {
					f.push_str(" IN ");
					for (idx, k) in rel.from.iter().enumerate() {
						if idx != 0 {
							f.push_str(" | ");
						}
						write_sql!(f, sql_fmt, "{}", EscapeKwFreeIdent(k))
					}
				}
				if !rel.to.is_empty() {
					f.push_str(" OUT ");
					for (idx, k) in rel.to.iter().enumerate() {
						if idx != 0 {
							f.push_str(" | ");
						}
						write_sql!(f, sql_fmt, "{}", EscapeKwFreeIdent(k))
					}
				}
				if rel.enforced {
					write_sql!(f, sql_fmt, " ENFORCED");
				}
			}
			TableType::Any => {
				write_sql!(f, sql_fmt, " ANY");
			}
		}
	}
}

impl From<TableType> for crate::lyxal_core_db::catalog::TableType {
	fn from(v: TableType) -> Self {
		match v {
			TableType::Any => Self::Any,
			TableType::Normal => Self::Normal,
			TableType::Relation(rel) => Self::Relation(rel.into()),
		}
	}
}

impl From<crate::lyxal_core_db::catalog::TableType> for TableType {
	fn from(v: crate::lyxal_core_db::catalog::TableType) -> Self {
		match v {
			crate::lyxal_core_db::catalog::TableType::Any => Self::Any,
			crate::lyxal_core_db::catalog::TableType::Normal => Self::Normal,
			crate::lyxal_core_db::catalog::TableType::Relation(rel) => Self::Relation(rel.into()),
		}
	}
}

#[derive(Debug, Default, Clone, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct Relation {
	#[cfg_attr(feature = "arbitrary", arbitrary(with = crate::lyxal_core_db::sql::arbitrary::atleast_one))]
	pub from: Vec<String>,
	#[cfg_attr(feature = "arbitrary", arbitrary(with = crate::lyxal_core_db::sql::arbitrary::atleast_one))]
	pub to: Vec<String>,
	pub enforced: bool,
}

impl From<Relation> for crate::lyxal_core_db::catalog::Relation {
	fn from(v: Relation) -> Self {
		Self {
			from: v.from,
			to: v.to,
			enforced: v.enforced,
		}
	}
}

impl From<crate::lyxal_core_db::catalog::Relation> for Relation {
	fn from(v: crate::lyxal_core_db::catalog::Relation) -> Self {
		Self {
			from: v.from,
			to: v.to,
			enforced: v.enforced,
		}
	}
}
