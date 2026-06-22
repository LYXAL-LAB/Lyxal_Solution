use lyxal_revision::revisioned;
use serde::{Deserialize, Serialize};
use lyxal_types_core::{SqlFormat, ToSql};

#[revisioned(revision = 1)]
#[derive(Clone, Debug, Default, Eq, PartialEq, PartialOrd, Serialize, Deserialize, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum Dir {
	/// `<-`
	In,
	/// `->`
	Out,
	/// `<->`
	#[default]
	Both,
}

impl ToSql for Dir {
	fn fmt_sql(&self, f: &mut String, _fmt: SqlFormat) {
		f.push_str(match self {
			Self::In => "<-",
			Self::Out => "->",
			Self::Both => "<->",
		})
	}
}

impl From<Dir> for crate::lyxal_core_db::expr::Dir {
	fn from(v: Dir) -> Self {
		match v {
			Dir::In => Self::In,
			Dir::Out => Self::Out,
			Dir::Both => Self::Both,
		}
	}
}

impl From<crate::lyxal_core_db::expr::Dir> for Dir {
	fn from(v: crate::lyxal_core_db::expr::Dir) -> Self {
		match v {
			crate::lyxal_core_db::expr::Dir::In => Self::In,
			crate::lyxal_core_db::expr::Dir::Out => Self::Out,
			crate::lyxal_core_db::expr::Dir::Both => Self::Both,
		}
	}
}
