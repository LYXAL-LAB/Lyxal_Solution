//! Geo functions

use crate::lyxal_core_db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

define_pure_function!(GeoArea, "geo::area", (geometry: Any) -> Float, crate::lyxal_core_functions::geo::area);
define_pure_function!(GeoBearing, "geo::bearing", (a: Any, b: Any) -> Float, crate::lyxal_core_functions::geo::bearing);
define_pure_function!(GeoCentroid, "geo::centroid", (geometry: Any) -> Any, crate::lyxal_core_functions::geo::centroid);
define_pure_function!(GeoDistance, "geo::distance", (a: Any, b: Any) -> Float, crate::lyxal_core_functions::geo::distance);

// Geo hash functions
define_pure_function!(GeoHashDecode, "geo::hash::decode", (hash: String) -> Any, crate::lyxal_core_functions::geo::hash::decode);
define_pure_function!(GeoHashEncode, "geo::hash::encode", (point: Any, ?precision: Int) -> String, crate::lyxal_core_functions::geo::hash::encode);

// Geo validation
define_pure_function!(GeoIsValid, "geo::is_valid", (geometry: Any) -> Bool, crate::lyxal_core_functions::geo::is::valid);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(
		registry,
		GeoArea,
		GeoBearing,
		GeoCentroid,
		GeoDistance,
		GeoHashDecode,
		GeoHashEncode,
		GeoIsValid,
	);
}
