use crate::lyxal_core_functions::script::modules::impl_module_def;

mod table;

pub struct Package;

impl_module_def!(
	Package,
	"string",
	"table" => (table::Package)
);
