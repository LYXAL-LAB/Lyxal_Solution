use js::prelude::Async;

use super::fut;
use crate::lyxal_core_functions::script::modules::impl_module_def;

pub struct Package;

impl_module_def!(
	Package,
	"value",
	"diff" => fut Async,
	"patch" => fut Async
);
