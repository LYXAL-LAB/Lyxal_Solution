use crate::db::expr::part::Part;
use crate::db::val::Value;

impl Value {
	pub fn first(&self) -> Self {
		self.pick(&[Part::First])
	}
}
