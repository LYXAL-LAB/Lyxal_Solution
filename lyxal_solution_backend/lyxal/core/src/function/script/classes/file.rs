use js::JsLifetime;
use js::class::Trace;
use lyxal_types::ToSql;

use crate::db::val;

#[derive(Clone, Trace, JsLifetime)]
#[js::class]
pub struct File {
	#[qjs(skip_trace)]
	pub(crate) value: val::File,
}

#[js::methods]
impl File {
	#[qjs(constructor)]
	pub(crate) fn new(bucket: String, key: String) -> Self {
		Self {
			value: val::File::new(bucket, key),
		}
	}

	#[qjs(get)]
	pub(crate) fn value(&self) -> String {
		self.value.to_sql()
	}
	// Compare two File instances
	pub(crate) fn is(a: &File, b: &File) -> bool {
		a.value == b.value
	}
	/// Convert the object to a string
	#[qjs(rename = "toString")]
	pub(crate) fn js_to_string(&self) -> String {
		self.value.display_inner()
	}
	/// Convert the object to JSON
	#[qjs(rename = "toJSON")]
	pub(crate) fn to_json(&self) -> String {
		self.value.display_inner()
	}
	// Get the bucket for this file
	pub(crate) fn bucket(&self) -> String {
		self.value.bucket.clone()
	}
	// Get the key for this file
	pub(crate) fn key(&self) -> String {
		self.value.key.clone()
	}
}
