use std::fmt::{Display, Formatter};

use lyxal_revision::{DeserializeRevisioned, Revisioned, SerializeRevisioned, revisioned};
use serde::{Deserialize, Serialize};
use storekey::{BorrowDecode, Encode};
use lyxal_types_core::{SqlFormat, ToSql};

use crate::lyxal_core_db::catalog::NamespaceId;
use crate::lyxal_core_db::expr::ChangeFeed;
use crate::lyxal_core_db::expr::statements::info::InfoStructure;
use crate::lyxal_core_kvs::impl_kv_value_revisioned;
use crate::lyxal_core_db::sql::statements::define::DefineDatabaseStatement;
use crate::lyxal_core_db::sql::{Expr, Idiom, Literal};
use crate::lyxal_core_db::val::Value;
use crate::map;

#[derive(
	Debug,
	Clone,
	Copy,
	PartialEq,
	Eq,
	PartialOrd,
	Ord,
	Hash,
	Serialize,
	Deserialize,
	Encode,
	BorrowDecode,
)]
#[cfg_attr(feature = "arbitrary", derive(arbitrary::Arbitrary))]
pub struct DatabaseId(pub u32);

impl_kv_value_revisioned!(DatabaseId);

impl Revisioned for DatabaseId {
	fn lyxal_core_revision() -> u16 {
		1
	}
}

impl SerializeRevisioned for DatabaseId {
	#[inline]
	fn serialize_revisioned<W: std::io::Write>(
		&self,
		writer: &mut W,
	) -> Result<(), lyxal_revision::Error> {
		SerializeRevisioned::serialize_revisioned(&self.0, writer)
	}
}

impl DeserializeRevisioned for DatabaseId {
	#[inline]
	fn deserialize_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, lyxal_revision::Error> {
		DeserializeRevisioned::deserialize_revisioned(reader).map(DatabaseId)
	}
}

impl Display for DatabaseId {
	fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
		write!(f, "{}", self.0)
	}
}

impl From<u32> for DatabaseId {
	fn from(value: u32) -> Self {
		Self(value)
	}
}

#[revisioned(revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub struct DatabaseDefinition {
	pub(crate) namespace_id: NamespaceId,
	pub(crate) database_id: DatabaseId,
	pub(crate) name: String,
	pub(crate) comment: Option<String>,
	pub(crate) changefeed: Option<ChangeFeed>,
	pub(crate) strict: bool,
}
impl_kv_value_revisioned!(DatabaseDefinition);

impl DatabaseDefinition {
	fn to_sql_definition(&self) -> DefineDatabaseStatement {
		DefineDatabaseStatement {
			name: Expr::Idiom(Idiom::field(self.name.clone())),
			comment: self
				.comment
				.clone()
				.map(|v| Expr::Literal(Literal::String(v)))
				.unwrap_or(Expr::Literal(Literal::None)),
			changefeed: self.changefeed.map(|v| v.into()),
			..Default::default()
		}
	}
}

impl ToSql for DatabaseDefinition {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		self.to_sql_definition().fmt_sql(f, fmt)
	}
}

impl InfoStructure for DatabaseDefinition {
	fn structure(self) -> Value {
		Value::from(map! {
			"name".to_string() => self.name.into(),
			"comment".to_string(), if let Some(v) = self.comment => v.into(),
			"id".to_string() => self.database_id.0.into(),
		})
	}
}
