use crate::db::expr::part::Part;
use crate::db::val::Value;

impl Value {
	/// Returns the equivalent of `self.pick(&[Part::All])`
	pub fn all(&self) -> Self {
		self.pick(&[Part::All])
	}
}
