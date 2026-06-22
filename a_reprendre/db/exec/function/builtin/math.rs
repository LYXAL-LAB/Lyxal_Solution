//! Math functions

use crate::lyxal_core_db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

// Single argument math functions
define_pure_function!(MathAbs, "math::abs", (value: Number) -> Number, crate::lyxal_core_functions::math::abs);
define_pure_function!(MathAcos, "math::acos", (value: Number) -> Number, crate::lyxal_core_functions::math::acos);
define_pure_function!(MathAcot, "math::acot", (value: Number) -> Number, crate::lyxal_core_functions::math::acot);
define_pure_function!(MathAsin, "math::asin", (value: Number) -> Number, crate::lyxal_core_functions::math::asin);
define_pure_function!(MathAtan, "math::atan", (value: Number) -> Number, crate::lyxal_core_functions::math::atan);
define_pure_function!(MathCeil, "math::ceil", (value: Number) -> Number, crate::lyxal_core_functions::math::ceil);
define_pure_function!(MathCos, "math::cos", (value: Number) -> Number, crate::lyxal_core_functions::math::cos);
define_pure_function!(MathCot, "math::cot", (value: Number) -> Number, crate::lyxal_core_functions::math::cot);
define_pure_function!(MathDeg2rad, "math::deg2rad", (value: Number) -> Number, crate::lyxal_core_functions::math::deg2rad);
define_pure_function!(MathFloor, "math::floor", (value: Number) -> Number, crate::lyxal_core_functions::math::floor);
define_pure_function!(MathLn, "math::ln", (value: Number) -> Number, crate::lyxal_core_functions::math::ln);
define_pure_function!(MathLog10, "math::log10", (value: Number) -> Number, crate::lyxal_core_functions::math::log10);
define_pure_function!(MathLog2, "math::log2", (value: Number) -> Number, crate::lyxal_core_functions::math::log2);
define_pure_function!(MathRad2deg, "math::rad2deg", (value: Number) -> Number, crate::lyxal_core_functions::math::rad2deg);
define_pure_function!(MathRound, "math::round", (value: Number) -> Number, crate::lyxal_core_functions::math::round);
define_pure_function!(MathSign, "math::sign", (value: Number) -> Number, crate::lyxal_core_functions::math::sign);
define_pure_function!(MathSin, "math::sin", (value: Number) -> Number, crate::lyxal_core_functions::math::sin);
define_pure_function!(MathSqrt, "math::sqrt", (value: Number) -> Number, crate::lyxal_core_functions::math::sqrt);
define_pure_function!(MathTan, "math::tan", (value: Number) -> Number, crate::lyxal_core_functions::math::tan);

// Two argument math functions
define_pure_function!(MathBottom, "math::bottom", (array: Any, count: Int) -> Any, crate::lyxal_core_functions::math::bottom);
define_pure_function!(MathFixed, "math::fixed", (value: Number, precision: Int) -> Number, crate::lyxal_core_functions::math::fixed);
define_pure_function!(MathLog, "math::log", (value: Number, base: Number) -> Number, crate::lyxal_core_functions::math::log);
define_pure_function!(MathPow, "math::pow", (base: Number, exponent: Number) -> Number, crate::lyxal_core_functions::math::pow);
define_pure_function!(MathTop, "math::top", (array: Any, count: Int) -> Any, crate::lyxal_core_functions::math::top);

// Three argument math functions
define_pure_function!(MathClamp, "math::clamp", (value: Number, min: Number, max: Number) -> Number, crate::lyxal_core_functions::math::clamp);
define_pure_function!(MathLerp, "math::lerp", (a: Number, b: Number, t: Number) -> Number, crate::lyxal_core_functions::math::lerp);
define_pure_function!(MathLerpangle, "math::lerpangle", (a: Number, b: Number, t: Number) -> Number, crate::lyxal_core_functions::math::lerpangle);

// Array aggregate math functions (operate on array of numbers)
define_pure_function!(MathInterquartile, "math::interquartile", (array: Any) -> Number, crate::lyxal_core_functions::math::interquartile);
define_pure_function!(MathMax, "math::max", (array: Any) -> Number, crate::lyxal_core_functions::math::max);
define_pure_function!(MathMean, "math::mean", (array: Any) -> Number, crate::lyxal_core_functions::math::mean);
define_pure_function!(MathMedian, "math::median", (array: Any) -> Number, crate::lyxal_core_functions::math::median);
define_pure_function!(MathMidhinge, "math::midhinge", (array: Any) -> Number, crate::lyxal_core_functions::math::midhinge);
define_pure_function!(MathMin, "math::min", (array: Any) -> Number, crate::lyxal_core_functions::math::min);
define_pure_function!(MathMode, "math::mode", (array: Any) -> Number, crate::lyxal_core_functions::math::mode);
define_pure_function!(MathProduct, "math::product", (array: Any) -> Number, crate::lyxal_core_functions::math::product);
define_pure_function!(MathSpread, "math::spread", (array: Any) -> Number, crate::lyxal_core_functions::math::spread);
define_pure_function!(MathStddev, "math::stddev", (array: Any) -> Number, crate::lyxal_core_functions::math::stddev);
define_pure_function!(MathSum, "math::sum", (array: Any) -> Number, crate::lyxal_core_functions::math::sum);
define_pure_function!(MathTrimean, "math::trimean", (array: Any) -> Number, crate::lyxal_core_functions::math::trimean);
define_pure_function!(MathVariance, "math::variance", (array: Any) -> Number, crate::lyxal_core_functions::math::variance);

// Two argument array aggregate functions
define_pure_function!(MathNearestrank, "math::nearestrank", (array: Any, percentile: Number) -> Number, crate::lyxal_core_functions::math::nearestrank);
define_pure_function!(MathPercentile, "math::percentile", (array: Any, percentile: Number) -> Number, crate::lyxal_core_functions::math::percentile);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(
		registry,
		MathAbs,
		MathAcos,
		MathAcot,
		MathAsin,
		MathAtan,
		MathBottom,
		MathCeil,
		MathClamp,
		MathCos,
		MathCot,
		MathDeg2rad,
		MathFixed,
		MathFloor,
		MathInterquartile,
		MathLerp,
		MathLerpangle,
		MathLn,
		MathLog,
		MathLog10,
		MathLog2,
		MathMax,
		MathMean,
		MathMedian,
		MathMidhinge,
		MathMin,
		MathMode,
		MathNearestrank,
		MathPercentile,
		MathPow,
		MathProduct,
		MathRad2deg,
		MathRound,
		MathSign,
		MathSin,
		MathSpread,
		MathSqrt,
		MathStddev,
		MathSum,
		MathTan,
		MathTop,
		MathTrimean,
		MathVariance,
	);
}
