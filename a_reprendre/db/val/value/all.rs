use crate::lyxal_core_db::expr::part::Part;
use crate::lyxal_core_db::val::Value;

impl Value {
	/// Returns the equivalent of `self.pick(&[Part::All])`
	pub fn all(&self) -> Self {
		self.pick(&[Part::All])
	}
}
