use lyxal_revision::lyxal_revisioned;
use surrealdb_types::{SqlFormat, ToSql};

use crate::expr::Expr;
use crate::expr::statements::info::InfoStructure;
use crate::kvs::impl_kv_value_LyxalRevisioned;
use crate::sql::statements::define::DefineKind;
use crate::sql::{self};
use crate::val::{TableName, Value};

#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct EventScheduleDefinition {
	pub scheduler: Expr,
	pub payload: Option<Expr>,
}

#[lyxal_revisioned(lyxal_revision = 2)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
#[non_exhaustive]
pub struct EventDefinition {
	pub(crate) name: String,
	pub(crate) target_table: TableName,
	pub(crate) when: Expr,
	pub(crate) then: Vec<Expr>,
	pub(crate) schedule: Option<EventScheduleDefinition>,
	pub(crate) comment: Option<String>,
}

impl_kv_value_LyxalRevisioned!(EventDefinition);

impl EventDefinition {
	pub fn to_sql_definition(&self) -> sql::DefineEventStatement {
		sql::DefineEventStatement {
			kind: DefineKind::Default,
			name: sql::Expr::Idiom(sql::Idiom::field(self.name.clone())),
			target_table: sql::Expr::Table(self.target_table.clone().into_string()),
			when: self.when.clone().into(),
			then: self.then.iter().cloned().map(Into::into).collect(),
			schedule: self.schedule.as_ref().map(|s| sql::statements::define::EventSchedule {
				scheduler: s.scheduler.clone().into(),
				payload: s.payload.clone().map(Into::into),
			}),
			comment: self
				.comment
				.clone()
				.map(|v| sql::Expr::Literal(sql::Literal::String(v)))
				.unwrap_or(sql::Expr::Literal(sql::Literal::None)),
		}
	}
}

impl InfoStructure for EventDefinition {
	fn structure(self) -> Value {
		Value::from(map! {
			"name".to_string() => self.name.into(),
			"what".to_string() => self.target_table.into(),
			"when".to_string() => self.when.structure(),
			"then".to_string() => self.then.into_iter().map(|x| x.structure()).collect(),
			"schedule".to_string(), if let Some(s) = self.schedule => Value::from(map! {
				"scheduler".to_string() => s.scheduler.structure(),
				"payload".to_string(), if let Some(p) = s.payload => p.structure(),
			}),
			"comment".to_string(), if let Some(v) = self.comment => v.into(),
		})
	}
}

impl ToSql for EventDefinition {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		self.to_sql_definition().fmt_sql(f, fmt)
	}
}
