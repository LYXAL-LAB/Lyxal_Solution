use super::super::run;
use crate::function::script::modules::impl_module_def;

pub struct Package;

impl_module_def!(
	Package,
	"geo::hash",
	"encode" => run,
	"decode" => run
);
