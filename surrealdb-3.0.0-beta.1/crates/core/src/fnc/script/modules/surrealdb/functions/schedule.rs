use js::prelude::Async;

use super::fut;
use crate::fnc::script::modules::impl_module_def;

pub struct Package;

impl_module_def!(
	Package,
	"schedule",
	"add" => fut Async,
	"add_many" => fut Async,
	"once" => fut Async,
	"retry" => fut Async,
	"discard" => fut Async,
	"pause" => fut Async,
	"progress" => fut Async,
	"resume" => fut Async,
	"remove" => fut Async,
	"list" => fut Async,
	"history" => fut Async,
	"explain" => fut Async,
	"reset_circuit" => fut Async
);

