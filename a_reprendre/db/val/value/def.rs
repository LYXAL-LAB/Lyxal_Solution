use crate::lyxal_core_db::expr::paths::ID;
use crate::lyxal_core_db::val::{RecordId, Value};

impl Value {
	pub(crate) fn def(&mut self, val: RecordId) {
		self.put(&*ID, val.into())
	}
}
