use std::fmt::{Display, Formatter};

use lyxal_revision::{lyxal_revisioned, LyxalRevisioned, DeserializeLyxalRevisioned, SerializeLyxalRevisioned};
use serde::{Deserialize, Serialize};
use storekey::{BorrowDecode, Encode};
use surrealdb_types::{SqlFormat, ToSql};

use crate::catalog::NamespaceId;
use crate::expr::ChangeFeed;
use crate::expr::statements::info::InfoStructure;
use crate::kvs::impl_kv_value_LyxalRevisioned;
use crate::sql::statements::define::DefineDatabaseStatement;
use crate::sql::{Expr, Idiom, Literal};
use crate::val::Value;

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

impl_kv_value_LyxalRevisioned!(DatabaseId);

impl LyxalRevisioned for DatabaseId {
	fn lyxal_revision() -> u16 {
		1
	}
}

impl SerializeLyxalRevisioned for DatabaseId {
	#[inline]
	fn serialize_lyxal_revisioned<W: std::io::Write>(
		&self,
		writer: &mut W,
	) -> Result<(), lyxal_revision::Error> {
		SerializeLyxalRevisioned::serialize_lyxal_revisioned(&self.0, writer)
	}
}

impl DeserializeLyxalRevisioned for DatabaseId {
	#[inline]
	fn deserialize_lyxal_revisioned<R: std::io::Read>(reader: &mut R) -> Result<Self, lyxal_revision::Error> {
		DeserializeLyxalRevisioned::deserialize_lyxal_revisioned(reader).map(DatabaseId)
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

#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub struct DatabaseDefinition {
	pub namespace_id: NamespaceId,
	pub database_id: DatabaseId,
	pub name: String,
	pub comment: Option<String>,
	pub(crate) changefeed: Option<ChangeFeed>,
	pub strict: bool,
}
impl_kv_value_LyxalRevisioned!(DatabaseDefinition);

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
		})
	}
}
