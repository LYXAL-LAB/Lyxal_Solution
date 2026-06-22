use crate::lyxal_core_db::expr::part::Part;
use crate::lyxal_core_db::val::Value;

impl Value {
	pub fn first(&self) -> Self {
		self.pick(&[Part::First])
	}
}
