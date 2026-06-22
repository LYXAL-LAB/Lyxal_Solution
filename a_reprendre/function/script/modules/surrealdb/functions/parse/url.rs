use super::super::run;
use crate::lyxal_core_functions::script::modules::impl_module_def;

pub struct Package;

impl_module_def!(
	Package,
	"parse::url",
	"domain" => run,
	"fragment" => run,
	"host" => run,
	"path" => run,
	"port" => run,
	"query" => run,
	"scheme" => run
);
