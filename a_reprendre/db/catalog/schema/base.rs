use std::fmt;

use lyxal_revision::revisioned;

use crate::lyxal_core_db::expr::statements::info::InfoStructure;
use crate::lyxal_core_db::val::Value;

#[revisioned(revision = 1)]
#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
pub enum Base {
	#[default]
	Root,
	Ns,
	Db,
}

impl fmt::Display for Base {
	fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
		match self {
			Self::Ns => f.write_str("NAMESPACE"),
			Self::Db => f.write_str("DATABASE"),
			Self::Root => f.write_str("ROOT"),
		}
	}
}

impl InfoStructure for Base {
	fn structure(self) -> Value {
		self.to_string().into()
	}
}

impl From<Base> for crate::lyxal_core_db::expr::Base {
	fn from(v: Base) -> Self {
		match v {
			Base::Root => Self::Root,
			Base::Ns => Self::Ns,
			Base::Db => Self::Db,
		}
	}
}

impl From<crate::lyxal_core_db::expr::Base> for Base {
	fn from(v: crate::lyxal_core_db::expr::Base) -> Self {
		match v {
			crate::lyxal_core_db::expr::Base::Root => Self::Root,
			crate::lyxal_core_db::expr::Base::Ns => Self::Ns,
			crate::lyxal_core_db::expr::Base::Db => Self::Db,
		}
	}
}
