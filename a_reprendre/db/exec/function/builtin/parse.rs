//! Parse functions

use crate::lyxal_core_db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

// Email parsing
define_pure_function!(ParseEmailHost, "parse::email::host", (email: String) -> String, crate::lyxal_core_functions::parse::email::host);
define_pure_function!(ParseEmailUser, "parse::email::user", (email: String) -> String, crate::lyxal_core_functions::parse::email::user);

// URL parsing
define_pure_function!(ParseUrlDomain, "parse::url::domain", (url: String) -> String, crate::lyxal_core_functions::parse::url::domain);
define_pure_function!(ParseUrlFragment, "parse::url::fragment", (url: String) -> String, crate::lyxal_core_functions::parse::url::fragment);
define_pure_function!(ParseUrlHost, "parse::url::host", (url: String) -> String, crate::lyxal_core_functions::parse::url::host);
define_pure_function!(ParseUrlPath, "parse::url::path", (url: String) -> String, crate::lyxal_core_functions::parse::url::path);
define_pure_function!(ParseUrlPort, "parse::url::port", (url: String) -> Int, crate::lyxal_core_functions::parse::url::port);
define_pure_function!(ParseUrlQuery, "parse::url::query", (url: String) -> String, crate::lyxal_core_functions::parse::url::query);
define_pure_function!(ParseUrlScheme, "parse::url::scheme", (url: String) -> String, crate::lyxal_core_functions::parse::url::scheme);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(
		registry,
		ParseEmailHost,
		ParseEmailUser,
		ParseUrlDomain,
		ParseUrlFragment,
		ParseUrlHost,
		ParseUrlPath,
		ParseUrlPort,
		ParseUrlQuery,
		ParseUrlScheme,
	);
}
