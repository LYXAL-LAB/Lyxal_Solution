use crate::lyxal_core_db::sql::idiom::Idiom;

#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct Groups(pub Vec<Group>);

impl lyxal_types_core::ToSql for Groups {
	fn fmt_sql(&self, f: &mut String, fmt: lyxal_types_core::SqlFormat) {
		if self.0.is_empty() {
			f.push_str("GROUP ALL");
		} else {
			f.push_str("GROUP BY ");
			for (i, item) in self.0.iter().enumerate() {
				if i > 0 {
					fmt.write_separator(f);
				}
				item.fmt_sql(f, fmt);
			}
		}
	}
}

impl From<Groups> for crate::lyxal_core_db::expr::Groups {
	fn from(v: Groups) -> Self {
		Self(v.0.into_iter().map(Into::into).collect())
	}
}

impl From<crate::lyxal_core_db::expr::Groups> for Groups {
	fn from(v: crate::lyxal_core_db::expr::Groups) -> Self {
		Self(v.0.into_iter().map(Into::into).collect())
	}
}

#[derive(Clone, Debug, Default, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) struct Group(
	#[cfg_attr(feature = "arbitrary", arbitrary(with = crate::lyxal_core_db::sql::arbitrary::basic_idiom))]
	pub(crate) Idiom,
);

impl lyxal_types_core::ToSql for Group {
	fn fmt_sql(&self, f: &mut String, fmt: lyxal_types_core::SqlFormat) {
		self.0.fmt_sql(f, fmt);
	}
}

impl From<Group> for crate::lyxal_core_db::expr::Group {
	fn from(v: Group) -> Self {
		Self(v.0.into())
	}
}

impl From<crate::lyxal_core_db::expr::Group> for Group {
	fn from(v: crate::lyxal_core_db::expr::Group) -> Self {
		Self(v.0.into())
	}
}
