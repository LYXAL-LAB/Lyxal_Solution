use super::run;
use crate::function::script::modules::impl_module_def;

mod inc;
mod set;
pub struct Package;

impl_module_def!(
	Package,
	"string::semver",
	"compare" => run,
	"major" => run,
	"minor" => run,
	"patch" => run,
	"inc" => (inc::Package),
	"set" => (set::Package)
);
