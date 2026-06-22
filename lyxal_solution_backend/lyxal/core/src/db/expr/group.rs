use std::fmt::Debug;
use std::ops::Deref;

use revision::revisioned;

use crate::db::expr::idiom::Idiom;

#[revisioned(revision = 1)]
#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
pub(crate) struct Groups(pub(crate) Vec<Group>);

impl Groups {
	pub(crate) fn is_group_all_only(&self) -> bool {
		self.0.is_empty()
	}

	pub(crate) fn len(&self) -> usize {
		self.0.len()
	}
}

#[revisioned(revision = 1)]
#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
pub(crate) struct Group(pub(crate) Idiom);

impl Deref for Group {
	type Target = Idiom;
	fn deref(&self) -> &Self::Target {
		&self.0
	}
}

impl lyxal_types::ToSql for Groups {
	fn fmt_sql(&self, f: &mut String, fmt: lyxal_types::SqlFormat) {
		let sql_groups: crate::db::sql::Groups = self.clone().into();
		sql_groups.fmt_sql(f, fmt);
	}
}

impl lyxal_types::ToSql for Group {
	fn fmt_sql(&self, f: &mut String, fmt: lyxal_types::SqlFormat) {
		let sql_group: crate::db::sql::Group = self.clone().into();
		sql_group.fmt_sql(f, fmt);
	}
}
