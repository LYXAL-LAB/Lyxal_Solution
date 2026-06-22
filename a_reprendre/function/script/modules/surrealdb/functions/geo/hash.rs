use super::super::run;
use crate::lyxal_core_functions::script::modules::impl_module_def;

pub struct Package;

impl_module_def!(
	Package,
	"geo::hash",
	"encode" => run,
	"decode" => run
);
