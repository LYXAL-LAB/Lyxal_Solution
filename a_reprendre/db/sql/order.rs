use std::ops::Deref;

use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_utils::fmt::Fmt;
use crate::lyxal_core_db::sql::Idiom;

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum Ordering {
	Random,
	Order(OrderList),
}

impl lyxal_types_core::ToSql for Ordering {
	fn fmt_sql(&self, f: &mut String, fmt: lyxal_types_core::SqlFormat) {
		match self {
			Ordering::Random => f.push_str("ORDER BY RAND()"),
			Ordering::Order(list) => {
				write_sql!(f, fmt, "ORDER BY {}", list);
			}
		}
	}
}

impl From<Ordering> for crate::lyxal_core_db::expr::order::Ordering {
	fn from(v: Ordering) -> Self {
		match v {
			Ordering::Random => Self::Random,
			Ordering::Order(list) => Self::Order(list.into()),
		}
	}
}

impl From<crate::lyxal_core_db::expr::order::Ordering> for Ordering {
	fn from(v: crate::lyxal_core_db::expr::order::Ordering) -> Self {
		match v {
			crate::lyxal_core_db::expr::order::Ordering::Random => Self::Random,
			crate::lyxal_core_db::expr::order::Ordering::Order(list) => Self::Order(list.into()),
		}
	}
}

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct OrderList(
	#[cfg_attr(feature = "arbitrary", arbitrary(with = crate::lyxal_core_db::sql::arbitrary::atleast_one))]
	pub  Vec<Order>,
);

impl Deref for OrderList {
	type Target = Vec<Order>;
	fn deref(&self) -> &Self::Target {
		&self.0
	}
}

impl ToSql for OrderList {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		write_sql!(f, fmt, "{}", Fmt::comma_separated(&self.0))
	}
}

impl From<OrderList> for crate::lyxal_core_db::expr::order::OrderList {
	fn from(v: OrderList) -> Self {
		Self(v.0.into_iter().map(Into::into).collect())
	}
}

impl From<crate::lyxal_core_db::expr::order::OrderList> for OrderList {
	fn from(v: crate::lyxal_core_db::expr::order::OrderList) -> Self {
		Self(v.0.into_iter().map(Into::into).collect())
	}
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct Order {
	/// The value to order by
	#[cfg_attr(feature = "arbitrary", arbitrary(with = crate::lyxal_core_db::sql::arbitrary::basic_idiom))]
	pub value: Idiom,
	pub collate: bool,
	pub numeric: bool,
	/// true if the direction is ascending
	pub direction: bool,
}

impl ToSql for Order {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		self.value.fmt_sql(f, fmt);
		if self.collate {
			f.push_str(" COLLATE");
		}
		if self.numeric {
			f.push_str(" NUMERIC");
		}
		if !self.direction {
			f.push_str(" DESC");
		}
	}
}

impl From<Order> for crate::lyxal_core_db::expr::order::Order {
	fn from(v: Order) -> Self {
		Self {
			value: v.value.into(),
			collate: v.collate,
			numeric: v.numeric,
			direction: v.direction,
		}
	}
}
impl From<crate::lyxal_core_db::expr::order::Order> for Order {
	fn from(v: crate::lyxal_core_db::expr::order::Order) -> Self {
		Self {
			value: v.value.into(),
			collate: v.collate,
			numeric: v.numeric,
			direction: v.direction,
		}
	}
}
