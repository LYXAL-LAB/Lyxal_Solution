use std::fmt::Debug;

use anyhow::{Result, bail};
use lyxal_types_core::{SqlFormat, ToSql};

use crate::lyxal_core_db::catalog::ViewDefinition;
use crate::lyxal_core_db::catalog::aggregation::{AggregateFields, AggregationAnalysis};
use crate::lyxal_core_error::Error;
use crate::lyxal_core_db::expr::statements::info::InfoStructure;
use crate::lyxal_core_db::expr::{Cond, Fields, Groups, Value};
use crate::lyxal_core_db::val::TableName;

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct View {
	pub(crate) materialize: bool,
	pub(crate) expr: Fields,
	pub(crate) what: Vec<TableName>,
	pub(crate) cond: Option<Cond>,
	pub(crate) group: Option<Groups>,
}

impl View {
	pub(crate) fn to_definition(&self) -> Result<ViewDefinition> {
		if !self.materialize {
			return Ok(ViewDefinition::Select {
				fields: self.expr.clone(),
				tables: self.what.clone(),
				condition: self.cond.clone().map(|x| x.0),
				groups: self.group.clone(),
			});
		}

		let Some(group) = self.group.as_ref() else {
			// No group, nothing to aggregate.
			return Ok(ViewDefinition::Materialized {
				fields: self.expr.clone(),
				tables: self.what.clone(),
				condition: self.cond.clone().map(|x| x.0),
			});
		};

		let analysis = AggregationAnalysis::analyze_fields_groups(&self.expr, group, true)?;
		if let AggregateFields::Value(_) = analysis.fields {
			bail!(Error::InvalidAggregation {
				message: "the selector `VALUE` clause is not supported on DEFINE TABLE .. AS SELECT .. GROUP .. aggregates"
					.to_string()
			})
		}

		Ok(ViewDefinition::Aggregated {
			groups: group.clone(),
			fields: self.expr.clone(),

			analysis,
			tables: self.what.clone(),
			condition: self.cond.clone().map(|x| x.0),
		})
	}
}

impl ToSql for View {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		let sql_view: crate::lyxal_core_db::sql::View = self.clone().into();
		sql_view.fmt_sql(f, fmt);
	}
}
impl InfoStructure for View {
	fn structure(self) -> Value {
		self.to_sql().into()
	}
}
