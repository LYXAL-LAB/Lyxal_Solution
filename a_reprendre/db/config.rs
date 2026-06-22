use crate::lyxal_core_db::expr::statements::info::InfoStructure;
use crate::lyxal_core_db::val::Value;
use crate::lyxal_core_config::cnf::DynamicConfiguration;
use crate::map;

impl InfoStructure for DynamicConfiguration {
	fn structure(self) -> Value {
		let object = map! {
			"QUERY_TIMEOUT".to_string() => match self.get_query_timeout() {
				None => Value::None,
				Some(d) => d.into(),
			}
		};
		Value::Object(object.into())
	}
}
