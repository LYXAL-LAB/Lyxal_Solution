use super::run;
use crate::lyxal_core_functions::script::modules::impl_module_def;

pub struct Package;

impl_module_def!(
	Package,
	"vector::similarity",
	"cosine" => run,
	"jaccard" => run,
	"pearson" => run,
	"spearman" => run
);
