use js::prelude::Async;

use super::super::fut;
use crate::function::script::modules::impl_module_def;

pub struct Package;

impl_module_def!(
	Package,
	"crypto::pbkdf2",
	"compare" => fut Async,
	"generate" => fut Async
);
