use crate::db::expr::paths::ID;
use crate::db::val::{RecordId, Value};

impl Value {
	pub(crate) fn def(&mut self, val: RecordId) {
		self.put(&*ID, val.into())
	}
}
