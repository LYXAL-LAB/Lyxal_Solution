use super::run;
use crate::lyxal_core_functions::script::modules::impl_module_def;

mod hash;

pub struct Package;

impl_module_def!(
	Package,
	"geo",
	"area" => run,
	"bearing" => run,
	"centroid" => run,
	"distance" => run,
	"hash" => (hash::Package),
	"is_valid" => run
);
