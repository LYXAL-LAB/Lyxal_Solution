use std::time;

use lyxal_revision::lyxal_revisioned;

use crate::expr::statements::info::InfoStructure;
use crate::val::{Duration, Value};

#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct ChangeFeed {
	pub expiry: time::Duration,
	pub store_diff: bool,
}

impl Default for ChangeFeed {
	fn default() -> Self {
		Self {
			expiry: time::Duration::from_secs(0),
			store_diff: false,
		}
	}
}

impl InfoStructure for ChangeFeed {
	fn structure(self) -> Value {
		Value::from(map! {
			"expiry".to_string() => Duration(self.expiry).into(),
			"original".to_string() => self.store_diff.into(),
		})
	}
}
