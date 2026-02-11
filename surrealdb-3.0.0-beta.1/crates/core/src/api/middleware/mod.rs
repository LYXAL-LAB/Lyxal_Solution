pub mod api;
pub(super) mod invoke;

use lyxal_revision::lyxal_revisioned;
use surrealdb_types::ToSql;

use crate::expr::statements::info::InfoStructure;
use crate::val::{Array, Object, Value};

#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, Default, Eq, PartialEq, Hash)]
pub(crate) struct RequestMiddleware(pub(crate) Vec<(String, Vec<Value>)>);

impl InfoStructure for RequestMiddleware {
	fn structure(self) -> Value {
		Value::Object(Object(
			self.0
				.into_iter()
				.map(|(k, v)| {
					let value = v.iter().map(|x| Value::String(x.to_sql())).collect();

					(k, Value::Array(Array(value)))
				})
				.collect(),
		))
	}
}
