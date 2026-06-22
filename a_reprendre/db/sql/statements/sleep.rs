use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::types::PublicDuration;

#[derive(Clone, Debug, Default, Eq, PartialEq, PartialOrd, Hash)]
pub struct SleepStatement {
	pub(crate) duration: PublicDuration,
}

impl ToSql for SleepStatement {
	fn fmt_sql(&self, f: &mut String, sql_fmt: SqlFormat) {
		write_sql!(f, sql_fmt, "SLEEP {}", self.duration);
	}
}

impl From<SleepStatement> for crate::lyxal_core_db::expr::statements::SleepStatement {
	fn from(v: SleepStatement) -> Self {
		crate::lyxal_core_db::expr::statements::SleepStatement {
			duration: v.duration.into(),
		}
	}
}

impl From<crate::lyxal_core_db::expr::statements::SleepStatement> for SleepStatement {
	fn from(v: crate::lyxal_core_db::expr::statements::SleepStatement) -> Self {
		SleepStatement {
			duration: v.duration.into(),
		}
	}
}
