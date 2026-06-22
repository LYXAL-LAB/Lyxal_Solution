use anyhow::{Result, bail};
use chrono::offset::TimeZone;
use chrono::{DateTime, Datelike, DurationRound, Local, Timelike, Utc};

use super::args::Optional;
use crate::error::Error;
use crate::db::val::{Datetime, Duration, Number, Value};

pub(crate) fn ceil((val, duration): (Datetime, Duration)) -> Result<Value> {
	match chrono::Duration::from_std(*duration) {
		Ok(d) => {
			let floor_to_ceil = |floor: DateTime<Utc>| -> Option<DateTime<Utc>> {
				if floor == *val {
					Some(floor)
				} else {
					floor.checked_add_signed(d)
				}
			};
			// Check for zero duration.
			if d.is_zero() {
				return Ok(Value::Datetime(val));
			}
			let result = val.duration_trunc(d).ok().and_then(floor_to_ceil);

			match result {
				Some(v) => Ok(v.into()),
				_ => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
					name: String::from("time::ceil"),
					message: String::from(
						"The second argument must be a duration, and must be able to be represented as nanoseconds.",
					),
				})),
			}
		}
		_ => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
			name: String::from("time::ceil"),
			message: String::from(
				"The second argument must be a duration, and must be able to be represented as nanoseconds.",
			),
		})),
	}
}

pub(crate) fn add((dt, duration): (Datetime, Duration)) -> Result<Value> {
	match chrono::Duration::from_std(*duration) {
		Ok(d) => match dt.0.checked_add_signed(d) {
			Some(v) => Ok(Datetime(v).into()),
			None => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
				name: String::from("time::add"),
				message: String::from("The resulting datetime would overflow."),
			})),
		},
		_ => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
			name: String::from("time::add"),
			message: String::from("The second argument must be a valid duration."),
		})),
	}
}

pub(crate) fn sub((dt, duration): (Datetime, Duration)) -> Result<Value> {
	match chrono::Duration::from_std(*duration) {
		Ok(d) => match dt.0.checked_sub_signed(d) {
			Some(v) => Ok(Datetime(v).into()),
			None => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
				name: String::from("time::sub"),
				message: String::from("The resulting datetime would underflow."),
			})),
		},
		_ => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
			name: String::from("time::sub"),
			message: String::from("The second argument must be a valid duration."),
		})),
	}
}

pub(crate) fn diff((dt1, dt2): (Datetime, Datetime)) -> Result<Value> {
	match dt1.0.signed_duration_since(dt2.0).to_std() {
		Ok(d) => Ok(Duration::from(d).into()),
		Err(_) => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
			name: String::from("time::diff"),
			message: String::from("The resulting duration is out of representable bounds."),
		})),
	}
}

/// lyxal::time::add_business_days($datetime, $number) -> datetime
pub(crate) fn add_business_days((dt, days): (Datetime, Number)) -> Result<Value> {
	let Number::Int(mut days_to_add) = days else {
		return Err(anyhow::anyhow!("The second argument must be an integer"));
	};

	let mut current_dt = dt.0;
	let step = if days_to_add >= 0 { 1 } else { -1 };
	days_to_add = days_to_add.abs();

	while days_to_add > 0 {
		current_dt = current_dt.checked_add_signed(chrono::Duration::days(step))
			.ok_or_else(|| anyhow::anyhow!("Datetime overflow during business days calculation"))?;
		
		// On ne décompte le jour que si c'est un jour ouvré (Lundi-Vendredi)
		let weekday = current_dt.weekday().number_from_monday();
		if weekday <= 5 {
			days_to_add -= 1;
		}
	}

	Ok(Datetime(current_dt).into())
}

/// lyxal::time::with_timezone($datetime, $string) -> datetime
pub(crate) fn with_timezone((dt, tz_str): (Datetime, String)) -> Result<Value> {
	use chrono_tz::Tz;
	use std::str::FromStr;

	let tz = Tz::from_str(&tz_str)
		.map_err(|_| anyhow::Error::new(Error::InvalidFunctionArguments {
			name: String::from("time::with_timezone"),
			message: format!("'{}' is not a valid IANA timezone database name.", tz_str),
		}))?;

	let converted = dt.0.with_timezone(&tz);
	// On le ramène en Utc pour le stockage interne Lyxal tout en gardant l'instant
	Ok(Datetime(converted.with_timezone(&Utc)).into())
}

/// lyxal::time::humanize($datetime) -> string
pub(crate) fn humanize((dt,): (Datetime,)) -> Result<Value> {
	// Utilisation du temps relatif par rapport à 'maintenant'
	let now = Utc::now();
	let duration = dt.0.signed_duration_since(now);
	
	// Logique de simplification (on peut utiliser une crate ou le faire en dur)
	let seconds = duration.num_seconds();
	let abs_secs = seconds.abs();
	
	let res = if abs_secs < 60 {
		format!("{} seconds", seconds)
	} else if abs_secs < 3600 {
		format!("{} minutes", seconds / 60)
	} else if abs_secs < 86400 {
		format!("{} hours", seconds / 3600)
	} else {
		format!("{} days", seconds / 86400)
	};
	
	Ok(res.into())
}

pub(crate) fn day((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.day().into(),
		None => Datetime::now().day().into(),
	})
}

pub(crate) fn floor((val, duration): (Datetime, Duration)) -> Result<Value> {
	match chrono::Duration::from_std(*duration) {
		Ok(d) => {
			// Check for zero duration
			if d.is_zero() {
				return Ok(Value::Datetime(val));
			}
			match val.duration_trunc(d) {
				Ok(v) => Ok(v.into()),
				_ => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
					name: String::from("time::floor"),
					message: String::from(
						"The second argument must be a duration, and must be able to be represented as nanoseconds.",
					),
				})),
			}
		}
		_ => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
			name: String::from("time::floor"),
			message: String::from(
				"The second argument must be a duration, and must be able to be represented as nanoseconds.",
			),
		})),
	}
}

pub(crate) fn format((val, format): (Datetime, String)) -> Result<Value> {
	use std::fmt::Write;
	let mut res = String::new();
	let Ok(()) = write!(&mut res, "{}", val.format(&format)) else {
		bail!(Error::InvalidMethodArguments {
			name: "time::format".to_owned(),
			message: format!("`{}` is not a valid time formatting string", format)
		});
	};
	Ok(res.into())
}

pub(crate) fn group((val, group): (Datetime, String)) -> Result<Value> {
	match group.as_str() {
		"year" => Ok(Utc
			.with_ymd_and_hms(val.year(), 1, 1, 0, 0, 0)
			.earliest()
			.expect("valid datetime")
			.into()),
		"month" => Ok(Utc
			.with_ymd_and_hms(val.year(), val.month(), 1, 0, 0, 0)
			.earliest()
			.expect("valid datetime")
			.into()),
		"day" => Ok(Utc
			.with_ymd_and_hms(val.year(), val.month(), val.day(), 0, 0, 0)
			.earliest()
			.expect("valid datetime")
			.into()),
		"hour" => Ok(Utc
			.with_ymd_and_hms(val.year(), val.month(), val.day(), val.hour(), 0, 0)
			.earliest()
			.expect("valid datetime")
			.into()),
		"minute" => Ok(Utc
			.with_ymd_and_hms(val.year(), val.month(), val.day(), val.hour(), val.minute(), 0)
			.earliest()
			.expect("valid datetime")
			.into()),
		"second" => Ok(Utc
			.with_ymd_and_hms(
				val.year(),
				val.month(),
				val.day(),
				val.hour(),
				val.minute(),
				val.second(),
			)
			.earliest()
			.expect("valid datetime")
			.into()),
		_ => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
			name: String::from("time::group"),
			message: String::from(
				"The second argument must be a string, and can be one of 'year', 'month', 'day', 'hour', 'minute', or 'second'.",
			),
		})),
	}
}

pub(crate) fn hour((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.hour().into(),
		None => Datetime::now().hour().into(),
	})
}

pub(crate) fn max((array,): (Vec<Datetime>,)) -> Result<Value> {
	Ok(match array.into_iter().max() {
		Some(v) => v.into(),
		None => Value::None,
	})
}

pub(crate) fn min((array,): (Vec<Datetime>,)) -> Result<Value> {
	Ok(match array.into_iter().min() {
		Some(v) => v.into(),
		None => Value::None,
	})
}

pub(crate) fn minute((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.minute().into(),
		None => Datetime::now().minute().into(),
	})
}

pub(crate) fn month((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.month().into(),
		None => Datetime::now().month().into(),
	})
}

pub(crate) fn nano((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.timestamp_nanos_opt().unwrap_or_default().into(),
		None => Datetime::now().timestamp_nanos_opt().unwrap_or_default().into(),
	})
}

pub(crate) fn millis((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.timestamp_millis().into(),
		None => Datetime::now().timestamp_millis().into(),
	})
}

pub(crate) fn micros((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.timestamp_micros().into(),
		None => Datetime::now().timestamp_micros().into(),
	})
}

pub(crate) fn now(_: ()) -> Result<Value> {
	Ok(Datetime::now().into())
}

pub(crate) fn round((val, duration): (Datetime, Duration)) -> Result<Value> {
	match chrono::Duration::from_std(*duration) {
		Ok(d) => {
			// Check for zero duration
			if d.is_zero() {
				return Ok(Value::Datetime(val));
			}
			match val.duration_round(d) {
				Ok(v) => Ok(v.into()),
				_ => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
					name: String::from("time::round"),
					message: String::from(
						"The second argument must be a duration, and must be able to be represented as nanoseconds.",
					),
				})),
			}
		}
		_ => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
			name: String::from("time::round"),
			message: String::from(
				"The second argument must be a duration, and must be able to be represented as nanoseconds.",
			),
		})),
	}
}

pub(crate) fn second((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.second().into(),
		None => Datetime::now().second().into(),
	})
}

pub(crate) fn timezone(_: ()) -> Result<Value> {
	Ok(Local::now().offset().to_string().into())
}

pub(crate) fn unix((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.timestamp().into(),
		None => Datetime::now().timestamp().into(),
	})
}

pub(crate) fn wday((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.weekday().number_from_monday().into(),
		None => Datetime::now().weekday().number_from_monday().into(),
	})
}

pub(crate) fn week((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.iso_week().week().into(),
		None => Datetime::now().iso_week().week().into(),
	})
}

pub(crate) fn yday((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.ordinal().into(),
		None => Datetime::now().ordinal().into(),
	})
}

pub(crate) fn year((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
	Ok(match val {
		Some(v) => v.year().into(),
		None => Datetime::now().year().into(),
	})
}

pub(crate) fn set_year((dt, year): (Datetime, Number)) -> Result<Value> {
	let Number::Int(year) = year else {
		return Err(anyhow::anyhow!("Unable to set datetime to year {year}"));
	};

	let dt =
		dt.0.with_year(i32::try_from(year)?)
			.ok_or_else(|| anyhow::anyhow!("Unable to set datetime to year {year}"))?;

	Ok(Value::Datetime(Datetime(dt)))
}

pub(crate) fn set_month((dt, month): (Datetime, Number)) -> Result<Value> {
	let Number::Int(month) = month else {
		return Err(anyhow::anyhow!("Unable to set datetime to month {month}"));
	};

	match dt.0.with_month(u32::try_from(month)?) {
		Some(dt) => Ok(Value::Datetime(Datetime(dt))),
		None => Err(anyhow::anyhow!("Unable to set datetime to month {month}")),
	}
}

pub(crate) fn set_day((dt, day): (Datetime, Number)) -> Result<Value> {
	let Number::Int(day) = day else {
		return Err(anyhow::anyhow!("Unable to set datetime to day {day}"));
	};
	match dt.0.with_day(u32::try_from(day)?) {
		Some(dt) => Ok(Value::Datetime(Datetime(dt))),
		None => Err(anyhow::anyhow!("Unable to set datetime to day {day}")),
	}
}

pub(crate) fn set_hour((dt, hour): (Datetime, Number)) -> Result<Value> {
	let Number::Int(hour) = hour else {
		return Err(anyhow::anyhow!("Unable to set datetime to hour {hour}"));
	};
	match dt.0.with_hour(u32::try_from(hour)?) {
		Some(dt) => Ok(Value::Datetime(Datetime(dt))),
		None => Err(anyhow::anyhow!("Unable to set datetime to hour {hour}")),
	}
}

pub(crate) fn set_minute((dt, minute): (Datetime, Number)) -> Result<Value> {
	let Number::Int(minute) = minute else {
		return Err(anyhow::anyhow!("Unable to set datetime to {minute} minutes"));
	};
	match dt.0.with_minute(u32::try_from(minute)?) {
		Some(dt) => Ok(Value::Datetime(Datetime(dt))),
		None => Err(anyhow::anyhow!("Unable to set datetime to {minute} minutes")),
	}
}

pub(crate) fn set_second((dt, second): (Datetime, Number)) -> Result<Value> {
	let Number::Int(second) = second else {
		return Err(anyhow::anyhow!("Unable to set datetime to {second} seconds"));
	};
	match dt.0.with_second(u32::try_from(second)?) {
		Some(dt) => Ok(Value::Datetime(Datetime(dt))),
		None => Err(anyhow::anyhow!("Unable to set datetime to {second} seconds")),
	}
}

pub(crate) fn set_nanosecond((dt, nanos): (Datetime, Number)) -> Result<Value> {
	let Number::Int(nanos) = nanos else {
		return Err(anyhow::anyhow!("Unable to set datetime to {nanos} nanoseconds"));
	};
	match dt.0.with_nanosecond(u32::try_from(nanos)?) {
		Some(dt) => Ok(Value::Datetime(Datetime(dt))),
		None => Err(anyhow::anyhow!("Unable to set datetime to {nanos} nanoseconds")),
	}
}

pub mod is {
	use anyhow::Result;

	use crate::function::args::Optional;
	use crate::db::val::{Datetime, Value};

	pub(crate) fn leap_year((Optional(val),): (Optional<Datetime>,)) -> Result<Value> {
		Ok(match val {
			Some(v) => v.naive_utc().date().leap_year().into(),
			None => Datetime::now().naive_utc().date().leap_year().into(),
		})
	}
}

pub mod from {

	use anyhow::Result;
	use chrono::DateTime;
	use ulid::Ulid;

	use crate::error::Error;
	use crate::db::val::{Datetime, Uuid, Value};

	pub(crate) fn nanos((val,): (i64,)) -> Result<Value> {
		const NANOS_PER_SEC: i64 = 1_000_000_000;

		let seconds = val.div_euclid(NANOS_PER_SEC);
		let nanoseconds = val.rem_euclid(NANOS_PER_SEC) as u32;

		match DateTime::from_timestamp(seconds, nanoseconds) {
			Some(v) => Ok(Datetime::from(v).into()),
			None => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
				name: String::from("time::from_nanos"),
				message: String::from(
					"The argument must be a number of nanoseconds relative to January 1, 1970 0:00:00 UTC that produces a datetime between -262143-01-01T00:00:00Z and +262142-12-31T23:59:59Z.",
				),
			})),
		}
	}

	pub(crate) fn micros((val,): (i64,)) -> Result<Value> {
		match DateTime::from_timestamp_micros(val) {
			Some(v) => Ok(Datetime::from(v).into()),
			None => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
				name: String::from("time::from_micros"),
				message: String::from(
					"The argument must be a number of microseconds relative to January 1, 1970 0:00:00 UTC that produces a datetime between -262143-01-01T00:00:00Z and +262142-12-31T23:59:59Z.",
				),
			})),
		}
	}

	pub(crate) fn millis((val,): (i64,)) -> Result<Value> {
		match DateTime::from_timestamp_millis(val) {
			Some(v) => Ok(Datetime::from(v).into()),
			None => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
				name: String::from("time::from_millis"),
				message: String::from(
					"The argument must be a number of milliseconds relative to January 1, 1970 0:00:00 UTC that produces a datetime between -262143-01-01T00:00:00Z and +262142-12-31T23:59:59Z.",
				),
			})),
		}
	}

	pub(crate) fn secs((val,): (i64,)) -> Result<Value> {
		match DateTime::from_timestamp(val, 0) {
			Some(v) => Ok(Datetime::from(v).into()),
			None => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
				name: String::from("time::from_secs"),
				message: String::from(
					"The argument must be a number of seconds relative to January 1, 1970 0:00:00 UTC that produces a datetime between -262143-01-01T00:00:00Z and +262142-12-31T23:59:59Z.",
				),
			})),
		}
	}

	pub(crate) fn unix((val,): (i64,)) -> Result<Value> {
		match DateTime::from_timestamp(val, 0) {
			Some(v) => Ok(Datetime::from(v).into()),
			None => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
				name: String::from("time::from_unix"),
				message: String::from(
					"The argument must be a number of seconds relative to January 1, 1970 0:00:00 UTC that produces a datetime between -262143-01-01T00:00:00Z and +262142-12-31T23:59:59Z.",
				),
			})),
		}
	}

	pub(crate) fn ulid((val,): (String,)) -> Result<Value> {
		match Ulid::from_string(&val) {
			Ok(v) => Ok(Datetime::from(DateTime::from(v.datetime())).into()),
			_ => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
				name: String::from("time::from_ulid"),
				message: String::from(
					"The first argument must be a string, containing a valid ULID.",
				),
			})),
		}
	}

	pub(crate) fn uuid((val,): (Uuid,)) -> Result<Value> {
		match val.0.get_timestamp() {
			Some(v) => {
				let (s, ns) = v.to_unix();
				match Datetime::try_from((s as i64, ns)) {
					Ok(v) => Ok(v.into()),
					_ => fail!("Failed to convert UUID Timestamp to Datetime."),
				}
			}
			None => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
				name: String::from("time::from_uuid"),
				message: String::from("The first argument must be a v1, v6 or v7 UUID."),
			})),
		}
	}
}
