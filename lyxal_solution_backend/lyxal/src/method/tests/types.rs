use crate::types::LyxalValue;

pub const USER: &str = "user";

#[derive(Debug, Default, LyxalValue)]
#[lyxal(crate = "crate::types")]
pub struct User {
	pub id: String,
	pub name: String,
}
