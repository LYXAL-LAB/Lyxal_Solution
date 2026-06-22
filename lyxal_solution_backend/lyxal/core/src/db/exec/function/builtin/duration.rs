//! Duration functions

use crate::db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

// Duration component extractors
define_pure_function!(DurationDays, "duration::days", (value: Duration) -> Int, crate::function::duration::days);
define_pure_function!(DurationHours, "duration::hours", (value: Duration) -> Int, crate::function::duration::hours);
define_pure_function!(DurationMicros, "duration::micros", (value: Duration) -> Int, crate::function::duration::micros);
define_pure_function!(DurationMillis, "duration::millis", (value: Duration) -> Int, crate::function::duration::millis);
define_pure_function!(DurationMins, "duration::mins", (value: Duration) -> Int, crate::function::duration::mins);
define_pure_function!(DurationNanos, "duration::nanos", (value: Duration) -> Int, crate::function::duration::nanos);
define_pure_function!(DurationSecs, "duration::secs", (value: Duration) -> Int, crate::function::duration::secs);
define_pure_function!(DurationWeeks, "duration::weeks", (value: Duration) -> Int, crate::function::duration::weeks);
define_pure_function!(DurationYears, "duration::years", (value: Duration) -> Int, crate::function::duration::years);

// Duration constructors
define_pure_function!(DurationFromDays, "duration::from_days", (value: Int) -> Duration, crate::function::duration::from::days);
define_pure_function!(DurationFromHours, "duration::from_hours", (value: Int) -> Duration, crate::function::duration::from::hours);
define_pure_function!(DurationFromMicros, "duration::from_micros", (value: Int) -> Duration, crate::function::duration::from::micros);
define_pure_function!(DurationFromMillis, "duration::from_millis", (value: Int) -> Duration, crate::function::duration::from::millis);
define_pure_function!(DurationFromMins, "duration::from_mins", (value: Int) -> Duration, crate::function::duration::from::mins);
define_pure_function!(DurationFromNanos, "duration::from_nanos", (value: Int) -> Duration, crate::function::duration::from::nanos);
define_pure_function!(DurationFromSecs, "duration::from_secs", (value: Int) -> Duration, crate::function::duration::from::secs);
define_pure_function!(DurationFromString, "duration::from::string", (value: String) -> Duration, crate::function::duration::from::string);
define_pure_function!(DurationFromWeeks, "duration::from_weeks", (value: Int) -> Duration, crate::function::duration::from::weeks);




pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(
		registry,
		DurationDays,
		DurationFromDays,
		DurationFromHours,
		DurationFromMicros,
		DurationFromMillis,
		DurationFromMins,
		DurationFromNanos,
		DurationFromSecs,
		DurationFromString,
		DurationFromWeeks,
		DurationHours,
		DurationMicros,
		DurationMillis,
		DurationMins,
		DurationNanos,
		DurationSecs,
		DurationWeeks,
		DurationYears,
	);
}
