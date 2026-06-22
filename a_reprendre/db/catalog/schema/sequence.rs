use std::time::Duration;

use lyxal_revision::revisioned;
use lyxal_types_core::{SqlFormat, ToSql};

use crate::lyxal_core_db::expr::statements::info::InfoStructure;
use crate::lyxal_core_kvs::impl_kv_value_revisioned;
use crate::lyxal_core_db::sql;
use crate::lyxal_core_db::sql::statements::define::{DefineKind, DefineSequenceStatement};
use crate::types::PublicDuration;
use crate::lyxal_core_db::val::Value;
use crate::map;

#[revisioned(revision = 1)]
#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
pub struct SequenceDefinition {
	pub name: String,
	pub batch: u32,
	pub start: i64,
	pub timeout: Option<Duration>,
}

impl_kv_value_revisioned!(SequenceDefinition);

impl SequenceDefinition {
	fn to_sql_definition(&self) -> DefineSequenceStatement {
		DefineSequenceStatement {
			kind: DefineKind::Default,
			name: sql::Expr::Idiom(sql::Idiom::field(self.name.clone())),
			batch: sql::Expr::Literal(sql::Literal::Integer(self.batch as i64)),
			start: sql::Expr::Literal(sql::Literal::Integer(self.start)),
			timeout: sql::Expr::Literal(
				self.timeout
					.map(|x| sql::Literal::Duration(PublicDuration::from_std(x)))
					.unwrap_or(sql::Literal::None),
			),
		}
	}
}

impl InfoStructure for SequenceDefinition {
	fn structure(self) -> Value {
		Value::from(map! {
				"name".to_string() => self.name.into(),
				"batch".to_string() => Value::from(self.batch).structure(),
				"start".to_string() => Value::from(self.start).structure(),
				"timeout".to_string() => self.timeout.as_ref().map(|d| {
					Value::Duration((*d).into())
				}).unwrap_or(Value::None),
		})
	}
}

impl ToSql for &SequenceDefinition {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		self.to_sql_definition().fmt_sql(f, fmt)
	}
}
