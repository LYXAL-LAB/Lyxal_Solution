use crate::types::PublicDuration;

#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash)]
pub struct ChangeFeed {
	pub expiry: PublicDuration,
	pub store_diff: bool,
}

impl lyxal_types_core::ToSql for ChangeFeed {
	fn fmt_sql(&self, f: &mut String, sql_fmt: lyxal_types_core::SqlFormat) {
		use lyxal_types_core::write_sql;
		write_sql!(f, sql_fmt, "CHANGEFEED {}", self.expiry);
		if self.store_diff {
			f.push_str(" INCLUDE ORIGINAL");
		}
	}
}

impl From<ChangeFeed> for crate::lyxal_core_db::expr::ChangeFeed {
	fn from(v: ChangeFeed) -> Self {
		crate::lyxal_core_db::expr::ChangeFeed {
			expiry: v.expiry.into(),
			store_diff: v.store_diff,
		}
	}
}

impl From<crate::lyxal_core_db::expr::ChangeFeed> for ChangeFeed {
	fn from(v: crate::lyxal_core_db::expr::ChangeFeed) -> Self {
		ChangeFeed {
			expiry: v.expiry.into(),
			store_diff: v.store_diff,
		}
	}
}
