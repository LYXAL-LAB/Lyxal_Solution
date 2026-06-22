use crate::utils::fmt::CoverStmts;
use crate::db::sql::Expr;

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct Reference {
	pub on_delete: ReferenceDeleteStrategy,
}

impl lyxal_types::ToSql for Reference {
	fn fmt_sql(&self, f: &mut String, fmt: lyxal_types::SqlFormat) {
		f.push_str("ON DELETE ");
		self.on_delete.fmt_sql(f, fmt);
	}
}

impl lyxal_types::ToSql for ReferenceDeleteStrategy {
	fn fmt_sql(&self, f: &mut String, fmt: lyxal_types::SqlFormat) {
		match self {
			ReferenceDeleteStrategy::Reject => f.push_str("REJECT"),
			ReferenceDeleteStrategy::Ignore => f.push_str("IGNORE"),
			ReferenceDeleteStrategy::Cascade => f.push_str("CASCADE"),
			ReferenceDeleteStrategy::Unset => f.push_str("UNSET"),
			ReferenceDeleteStrategy::Custom(v) => {
				f.push_str("THEN ");
				CoverStmts(v).fmt_sql(f, fmt);
			}
		}
	}
}

impl From<Reference> for crate::db::expr::reference::Reference {
	fn from(v: Reference) -> Self {
		Self {
			on_delete: v.on_delete.into(),
		}
	}
}
impl From<crate::db::expr::reference::Reference> for Reference {
	fn from(v: crate::db::expr::reference::Reference) -> Self {
		Self {
			on_delete: v.on_delete.into(),
		}
	}
}

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) enum ReferenceDeleteStrategy {
	Reject,
	Ignore,
	Cascade,
	Unset,
	Custom(Expr),
}

impl From<ReferenceDeleteStrategy> for crate::db::expr::reference::ReferenceDeleteStrategy {
	fn from(v: ReferenceDeleteStrategy) -> Self {
		match v {
			ReferenceDeleteStrategy::Reject => {
				crate::db::expr::reference::ReferenceDeleteStrategy::Reject
			}
			ReferenceDeleteStrategy::Ignore => {
				crate::db::expr::reference::ReferenceDeleteStrategy::Ignore
			}
			ReferenceDeleteStrategy::Cascade => {
				crate::db::expr::reference::ReferenceDeleteStrategy::Cascade
			}
			ReferenceDeleteStrategy::Unset => {
				crate::db::expr::reference::ReferenceDeleteStrategy::Unset
			}
			ReferenceDeleteStrategy::Custom(v) => {
				crate::db::expr::reference::ReferenceDeleteStrategy::Custom(v.into())
			}
		}
	}
}

impl From<crate::db::expr::reference::ReferenceDeleteStrategy> for ReferenceDeleteStrategy {
	fn from(v: crate::db::expr::reference::ReferenceDeleteStrategy) -> Self {
		match v {
			crate::db::expr::reference::ReferenceDeleteStrategy::Reject => {
				ReferenceDeleteStrategy::Reject
			}
			crate::db::expr::reference::ReferenceDeleteStrategy::Ignore => {
				ReferenceDeleteStrategy::Ignore
			}
			crate::db::expr::reference::ReferenceDeleteStrategy::Cascade => {
				ReferenceDeleteStrategy::Cascade
			}
			crate::db::expr::reference::ReferenceDeleteStrategy::Unset => {
				ReferenceDeleteStrategy::Unset
			}
			crate::db::expr::reference::ReferenceDeleteStrategy::Custom(v) => {
				ReferenceDeleteStrategy::Custom(v.into())
			}
		}
	}
}
