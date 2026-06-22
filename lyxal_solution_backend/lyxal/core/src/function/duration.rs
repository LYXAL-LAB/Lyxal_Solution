use anyhow::Result;

use crate::db::val::{Duration, Value};

pub(crate) fn days((val,): (Duration,)) -> Result<Value> {
	Ok(val.days().into())
}

pub(crate) fn hours((val,): (Duration,)) -> Result<Value> {
	Ok(val.hours().into())
}

pub(crate) fn micros((val,): (Duration,)) -> Result<Value> {
	Ok(val.micros().into())
}

pub(crate) fn millis((val,): (Duration,)) -> Result<Value> {
	Ok(val.millis().into())
}

pub(crate) fn mins((val,): (Duration,)) -> Result<Value> {
	Ok(val.mins().into())
}

pub(crate) fn nanos((val,): (Duration,)) -> Result<Value> {
	Ok(val.nanos().into())
}

pub(crate) fn secs((val,): (Duration,)) -> Result<Value> {
	Ok(val.secs().into())
}

pub(crate) fn weeks((val,): (Duration,)) -> Result<Value> {
	Ok(val.weeks().into())
}

pub(crate) fn years((val,): (Duration,)) -> Result<Value> {
	Ok(val.years().into())
}

pub mod from {

	use anyhow::Result;

	use crate::error::Error;
	use crate::db::val::{Duration, Value};

	pub(crate) fn days((val,): (i64,)) -> Result<Value> {
		// TODO: Deal with truncation:
		let val = val as u64;

		Duration::from_days(val)
			.map(|x| x.into())
			.ok_or_else(|| Error::ArithmeticOverflow(format!("duration::from_days({val})")))
			.map_err(anyhow::Error::new)
	}

	pub(crate) fn hours((val,): (i64,)) -> Result<Value> {
		// TODO: Deal with truncation:
		let val = val as u64;

		Duration::from_hours(val)
			.map(|x| x.into())
			.ok_or_else(|| Error::ArithmeticOverflow(format!("duration::from_hours({val})")))
			.map_err(anyhow::Error::new)
	}

	pub(crate) fn micros((val,): (i64,)) -> Result<Value> {
		// TODO: Deal with truncation:
		let val = val as u64;

		Ok(Duration::from_micros(val).into())
	}

	pub(crate) fn millis((val,): (i64,)) -> Result<Value> {
		// TODO: Deal with truncation:
		let val = val as u64;

		Ok(Duration::from_millis(val).into())
	}

	pub(crate) fn mins((val,): (i64,)) -> Result<Value> {
		// TODO: Deal with truncation:
		let val = val as u64;

		Duration::from_mins(val)
			.map(|x| x.into())
			.ok_or_else(|| Error::ArithmeticOverflow(format!("duration::from_mins({val})")))
			.map_err(anyhow::Error::new)
	}

	pub(crate) fn nanos((val,): (i64,)) -> Result<Value> {
		// TODO: Deal with truncation:
		let val = val as u64;

		Ok(Duration::from_nanos(val).into())
	}

	pub(crate) fn secs((val,): (i64,)) -> Result<Value> {
		// TODO: Deal with truncation:
		let val = val as u64;

		Ok(Duration::from_secs(val).into())
	}

	pub(crate) fn weeks((val,): (i64,)) -> Result<Value> {
		// TODO: Deal with truncation:
		let val = val as u64;

		Duration::from_weeks(val)
			.map(|x| x.into())
			.ok_or_else(|| Error::ArithmeticOverflow(format!("duration::from_weeks({val})")))
			.map_err(anyhow::Error::new)
	}

	pub(crate) fn string((val,): (String,)) -> Result<Value> {
		// On utilise le parseur natif de Duration de Lyxal (FromStr via syn::duration)
		match val.parse::<Duration>() {
			Ok(d) => Ok(d.into()),
			Err(_) => Err(anyhow::Error::new(Error::InvalidFunctionArguments {
				name: String::from("duration::from::string"),
				message: format!("'{}' is not a valid duration string", val),
			})),
		}
	}
}