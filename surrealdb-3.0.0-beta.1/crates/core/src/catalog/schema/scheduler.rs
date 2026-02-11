use crate::dbs::node::Timestamp;
use crate::kvs::KVValue;
use crate::val::Value;
use crate::expr::statements::info::InfoStructure;
use lyxal_revision::lyxal_revisioned;
use serde::{Deserialize, Serialize};
use surrealdb_types::{SqlFormat, ToSql};

/// Scheduler definition stored in the catalogue
#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct SchedulerDefinition {
    /// Unique name of the scheduler
	pub name: String,
    /// Whether the scheduler is enabled
	pub enabled: bool,
    /// Action to execute (e.g., "fn::run()")
	pub action: String,
    /// Optional comment
	pub comment: Option<String>,
    /// Creation timestamp
	pub created_at: Timestamp,
}

impl KVValue for SchedulerDefinition {
	fn kv_encode_value(&self) -> anyhow::Result<Vec<u8>> {
		Ok(lyxal_revision::to_vec(self)?)
	}

	fn kv_decode_value(bytes: Vec<u8>) -> anyhow::Result<Self> {
		Ok(lyxal_revision::from_slice(&bytes)?)
	}
}

impl InfoStructure for SchedulerDefinition {
	fn structure(self) -> Value {
		Value::from(map! {
			"name".to_string() => self.name.into(),
			"enabled".to_string() => self.enabled.into(),
			"action".to_string() => self.action.into(),
			"comment".to_string() => self.comment.map(Value::from).unwrap_or(Value::None),
		})
	}
}

impl ToSql for SchedulerDefinition {
	fn fmt_sql(&self, f: &mut String, _sql_fmt: SqlFormat) {
		f.push_str("DEFINE SCHEDULER ");
		f.push_str(&self.name);
		f.push_str(" ACTION ");
		f.push_str(&self.action);
		if !self.enabled {
			f.push_str(" DISABLED");
		}
		if let Some(ref comment) = self.comment {
			f.push_str(" COMMENT '");
			f.push_str(comment);
			f.push_str("'");
		}
	}
}

