//! Time functions

use crate::lyxal_core_db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

// No argument functions
define_pure_function!(TimeNow, "time::now", () -> Datetime, crate::lyxal_core_functions::time::now);

// Single datetime argument functions
define_pure_function!(TimeDay, "time::day", (value: Datetime) -> Int, crate::lyxal_core_functions::time::day);
define_pure_function!(TimeHour, "time::hour", (value: Datetime) -> Int, crate::lyxal_core_functions::time::hour);
define_pure_function!(TimeMicros, "time::micros", (value: Datetime) -> Int, crate::lyxal_core_functions::time::micros);
define_pure_function!(TimeMillis, "time::millis", (value: Datetime) -> Int, crate::lyxal_core_functions::time::millis);
define_pure_function!(TimeMinute, "time::minute", (value: Datetime) -> Int, crate::lyxal_core_functions::time::minute);
define_pure_function!(TimeMonth, "time::month", (value: Datetime) -> Int, crate::lyxal_core_functions::time::month);
define_pure_function!(TimeNano, "time::nano", (value: Datetime) -> Int, crate::lyxal_core_functions::time::nano);
define_pure_function!(TimeSecond, "time::second", (value: Datetime) -> Int, crate::lyxal_core_functions::time::second);
define_pure_function!(TimeTimezone, "time::timezone", (value: Datetime) -> String, crate::lyxal_core_functions::time::timezone);
define_pure_function!(TimeUnix, "time::unix", (value: Datetime) -> Int, crate::lyxal_core_functions::time::unix);
define_pure_function!(TimeWday, "time::wday", (value: Datetime) -> Int, crate::lyxal_core_functions::time::wday);
define_pure_function!(TimeWeek, "time::week", (value: Datetime) -> Int, crate::lyxal_core_functions::time::week);
define_pure_function!(TimeYday, "time::yday", (value: Datetime) -> Int, crate::lyxal_core_functions::time::yday);
define_pure_function!(TimeYear, "time::year", (value: Datetime) -> Int, crate::lyxal_core_functions::time::year);

// Two argument time functions
define_pure_function!(TimeCeil, "time::ceil", (value: Datetime, duration: Duration) -> Datetime, crate::lyxal_core_functions::time::ceil);
define_pure_function!(TimeFloor, "time::floor", (value: Datetime, duration: Duration) -> Datetime, crate::lyxal_core_functions::time::floor);
define_pure_function!(TimeFormat, "time::format", (value: Datetime, format: String) -> String, crate::lyxal_core_functions::time::format);
define_pure_function!(TimeGroup, "time::group", (value: Datetime, group: String) -> Datetime, crate::lyxal_core_functions::time::group);
define_pure_function!(TimeRound, "time::round", (value: Datetime, duration: Duration) -> Datetime, crate::lyxal_core_functions::time::round);
define_pure_function!(TimeSetYear, "time::set_year", (dt: Datetime, year: Number) -> Datetime, crate::lyxal_core_functions::time::set_year);
define_pure_function!(TimeSetMonth, "time::set_month", (dt: Datetime, month: Number) -> Datetime, crate::lyxal_core_functions::time::set_month);
define_pure_function!(TimeSetDay, "time::set_day", (dt: Datetime, day: Number) -> Datetime, crate::lyxal_core_functions::time::set_day);
define_pure_function!(TimeSetHour, "time::set_hour", (dt: Datetime, hour: Number) -> Datetime, crate::lyxal_core_functions::time::set_hour);
define_pure_function!(TimeSetMinute, "time::set_minute", (dt: Datetime, minute: Number) -> Datetime, crate::lyxal_core_functions::time::set_minute);
define_pure_function!(TimeSetSecond, "time::set_second", (dt: Datetime, minute: Number) -> Datetime, crate::lyxal_core_functions::time::set_second);
define_pure_function!(TimeSetNanosecond, "time::set_nanosecond", (dt: Datetime, nanos: Number) -> Datetime, crate::lyxal_core_functions::time::set_nanosecond);

// Array argument functions
define_pure_function!(TimeMax, "time::max", (array: Any) -> Datetime, crate::lyxal_core_functions::time::max);
define_pure_function!(TimeMin, "time::min", (array: Any) -> Datetime, crate::lyxal_core_functions::time::min);

// Time from:: constructors
define_pure_function!(TimeFromMicros, "time::from_micros", (value: Int) -> Datetime, crate::lyxal_core_functions::time::from::micros);
define_pure_function!(TimeFromMillis, "time::from_millis", (value: Int) -> Datetime, crate::lyxal_core_functions::time::from::millis);
define_pure_function!(TimeFromNanos, "time::from_nanos", (value: Int) -> Datetime, crate::lyxal_core_functions::time::from::nanos);
define_pure_function!(TimeFromSecs, "time::from_secs", (value: Int) -> Datetime, crate::lyxal_core_functions::time::from::secs);
define_pure_function!(TimeFromUlid, "time::from_ulid", (value: String) -> Datetime, crate::lyxal_core_functions::time::from::ulid);
define_pure_function!(TimeFromUnix, "time::from_unix", (value: Int) -> Datetime, crate::lyxal_core_functions::time::from::unix);
define_pure_function!(TimeFromUuid, "time::from_uuid", (value: Uuid) -> Datetime, crate::lyxal_core_functions::time::from::uuid);

// Time is:: functions
define_pure_function!(TimeIsLeapYear, "time::is_leap_year", (value: Datetime) -> Bool, crate::lyxal_core_functions::time::is::leap_year);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(
		registry,
		TimeCeil,
		TimeDay,
		TimeFloor,
		TimeFormat,
		TimeFromMicros,
		TimeFromMillis,
		TimeFromNanos,
		TimeFromSecs,
		TimeFromUlid,
		TimeFromUnix,
		TimeFromUuid,
		TimeGroup,
		TimeHour,
		TimeIsLeapYear,
		TimeMax,
		TimeMicros,
		TimeMillis,
		TimeMin,
		TimeMinute,
		TimeMonth,
		TimeNano,
		TimeNow,
		TimeRound,
		TimeSecond,
		TimeTimezone,
		TimeUnix,
		TimeWday,
		TimeWeek,
		TimeYday,
		TimeYear,
		TimeSetYear,
		TimeSetMonth,
		TimeSetDay,
		TimeSetHour,
		TimeSetMinute,
		TimeSetSecond,
		TimeSetNanosecond
	);
}
