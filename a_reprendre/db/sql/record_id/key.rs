use std::ops::Bound;

use lyxal_types_core::{SqlFormat, ToSql, write_sql};

use crate::lyxal_core_utils::fmt::{EscapeObjectKey, EscapeRidKey, Fmt};
use crate::lyxal_core_db::sql::CoverStmts;
use crate::lyxal_core_db::sql::literal::ObjectEntry;
use crate::lyxal_core_db::sql::{Expr, RecordIdKeyRangeLit};
use crate::types::{PublicRecordIdKey, PublicUuid};

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub enum RecordIdKeyGen {
	Rand,
	Ulid,
	Uuid,
}

impl From<RecordIdKeyGen> for crate::lyxal_core_db::expr::RecordIdKeyGen {
	fn from(value: RecordIdKeyGen) -> Self {
		match value {
			RecordIdKeyGen::Rand => crate::lyxal_core_db::expr::RecordIdKeyGen::Rand,
			RecordIdKeyGen::Ulid => crate::lyxal_core_db::expr::RecordIdKeyGen::Ulid,
			RecordIdKeyGen::Uuid => crate::lyxal_core_db::expr::RecordIdKeyGen::Uuid,
		}
	}
}

impl From<crate::lyxal_core_db::expr::RecordIdKeyGen> for RecordIdKeyGen {
	fn from(value: crate::lyxal_core_db::expr::RecordIdKeyGen) -> Self {
		match value {
			crate::lyxal_core_db::expr::RecordIdKeyGen::Rand => RecordIdKeyGen::Rand,
			crate::lyxal_core_db::expr::RecordIdKeyGen::Ulid => RecordIdKeyGen::Ulid,
			crate::lyxal_core_db::expr::RecordIdKeyGen::Uuid => RecordIdKeyGen::Uuid,
		}
	}
}

#[derive(Clone, Debug, PartialEq, Eq)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub(crate) enum RecordIdKeyLit {
	Number(i64),
	String(String),
	Uuid(PublicUuid),
	Array(Vec<Expr>),
	Object(Vec<ObjectEntry>),
	Generate(RecordIdKeyGen),
	Range(Box<RecordIdKeyRangeLit>),
}

impl RecordIdKeyLit {
	pub fn from_record_id_key(key: PublicRecordIdKey) -> Self {
		match key {
			PublicRecordIdKey::Number(x) => RecordIdKeyLit::Number(x),
			PublicRecordIdKey::String(x) => RecordIdKeyLit::String(x),
			PublicRecordIdKey::Uuid(x) => RecordIdKeyLit::Uuid(x),
			PublicRecordIdKey::Array(x) => {
				RecordIdKeyLit::Array(x.into_iter().map(Expr::from_public_value).collect())
			}
			PublicRecordIdKey::Object(x) => RecordIdKeyLit::Object(
				x.into_iter()
					.map(|(k, v)| ObjectEntry {
						key: k,
						value: Expr::from_public_value(v),
					})
					.collect(),
			),
			PublicRecordIdKey::Range(x) => {
				let range = x.into_inner();
				RecordIdKeyLit::Range(Box::new(RecordIdKeyRangeLit {
					start: match range.0 {
						Bound::Included(x) => Bound::Included(Self::from_record_id_key(x)),
						Bound::Excluded(x) => Bound::Excluded(Self::from_record_id_key(x)),
						Bound::Unbounded => Bound::Unbounded,
					},
					end: match range.1 {
						Bound::Included(x) => Bound::Included(Self::from_record_id_key(x)),
						Bound::Excluded(x) => Bound::Excluded(Self::from_record_id_key(x)),
						Bound::Unbounded => Bound::Unbounded,
					},
				}))
			}
		}
	}
}

impl From<RecordIdKeyLit> for crate::lyxal_core_db::expr::RecordIdKeyLit {
	fn from(value: RecordIdKeyLit) -> Self {
		match value {
			RecordIdKeyLit::Number(x) => crate::lyxal_core_db::expr::RecordIdKeyLit::Number(x),
			RecordIdKeyLit::String(x) => crate::lyxal_core_db::expr::RecordIdKeyLit::String(x),
			RecordIdKeyLit::Uuid(x) => {
				crate::lyxal_core_db::expr::RecordIdKeyLit::Uuid(crate::lyxal_core_db::val::Uuid(x.into_inner()))
			}
			RecordIdKeyLit::Array(x) => {
				crate::lyxal_core_db::expr::RecordIdKeyLit::Array(x.into_iter().map(From::from).collect())
			}
			RecordIdKeyLit::Object(x) => {
				crate::lyxal_core_db::expr::RecordIdKeyLit::Object(x.into_iter().map(From::from).collect())
			}
			RecordIdKeyLit::Generate(x) => crate::lyxal_core_db::expr::RecordIdKeyLit::Generate(x.into()),
			RecordIdKeyLit::Range(x) => crate::lyxal_core_db::expr::RecordIdKeyLit::Range(Box::new((*x).into())),
		}
	}
}

impl From<crate::lyxal_core_db::expr::RecordIdKeyLit> for RecordIdKeyLit {
	fn from(value: crate::lyxal_core_db::expr::RecordIdKeyLit) -> Self {
		match value {
			crate::lyxal_core_db::expr::RecordIdKeyLit::Number(x) => RecordIdKeyLit::Number(x),
			crate::lyxal_core_db::expr::RecordIdKeyLit::String(x) => RecordIdKeyLit::String(x),
			crate::lyxal_core_db::expr::RecordIdKeyLit::Uuid(uuid) => {
				RecordIdKeyLit::Uuid(lyxal_types_core::Uuid::from(uuid.0))
			}
			crate::lyxal_core_db::expr::RecordIdKeyLit::Array(exprs) => {
				RecordIdKeyLit::Array(exprs.into_iter().map(From::from).collect())
			}
			crate::lyxal_core_db::expr::RecordIdKeyLit::Object(items) => {
				RecordIdKeyLit::Object(items.into_iter().map(From::from).collect())
			}
			crate::lyxal_core_db::expr::RecordIdKeyLit::Generate(x) => RecordIdKeyLit::Generate(x.into()),
			crate::lyxal_core_db::expr::RecordIdKeyLit::Range(x) => RecordIdKeyLit::Range(Box::new((*x).into())),
		}
	}
}

impl ToSql for RecordIdKeyLit {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		match self {
			Self::Number(v) => write_sql!(f, fmt, "{v}"),
			Self::String(v) => EscapeRidKey(v).fmt_sql(f, fmt),
			Self::Uuid(v) => v.fmt_sql(f, fmt),
			Self::Array(v) => {
				f.push('[');
				if !v.is_empty() {
					let fmt = fmt.increment();
					write_sql!(f, fmt, "{}", Fmt::pretty_comma_separated(v.iter().map(CoverStmts)));
				}
				f.push(']');
			}
			Self::Object(v) => {
				if fmt.is_pretty() {
					f.push('{');
				} else {
					f.push_str("{ ");
				}
				if !v.is_empty() {
					let fmt = fmt.increment();
					write_sql!(
						f,
						fmt,
						"{}",
						Fmt::pretty_comma_separated(v.iter().map(|args| Fmt::new(
							args,
							|entry, f, fmt| write_sql!(
								f,
								fmt,
								"{}: {}",
								EscapeObjectKey(&entry.key), &entry.value
							)
						)),)
					);
				}
				if fmt.is_pretty() {
					f.push('}');
				} else {
					f.push_str(" }");
				}
			}
			Self::Generate(v) => match v {
				RecordIdKeyGen::Rand => f.push_str("rand()"),
				RecordIdKeyGen::Ulid => f.push_str("ulid()"),
				RecordIdKeyGen::Uuid => f.push_str("uuid()"),
			},
			Self::Range(v) => v.fmt_sql(f, fmt),
		}
	}
}
