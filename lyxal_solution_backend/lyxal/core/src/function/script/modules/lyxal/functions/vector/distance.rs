use super::run;
use crate::function::script::modules::impl_module_def;

pub struct Package;

impl_module_def!(
	Package,
	"vector::distance",
	"chebyshev" => run,
	"euclidean" => run,
	"hamming" => run,
	"knn" => run,
	"mahalanobis" => run,
	"manhattan" => run,
	"minkowski" => run
);
