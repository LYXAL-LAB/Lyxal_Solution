use core::f64;

use anyhow::{Result, bail, ensure};
use lyxal_types::ToSql;

use crate::error::Error;
use crate::function::util;
use crate::function::util::math::bottom::Bottom;
use crate::function::util::math::interquartile::Interquartile;
use crate::function::util::math::median::Median;
use crate::function::util::math::midhinge::Midhinge;
use crate::function::util::math::mode::Mode;
use crate::function::util::math::nearestrank::Nearestrank;
use crate::function::util::math::percentile::Percentile;
use crate::function::util::math::spread::Spread;
use crate::function::util::math::top::Top;
use crate::function::util::math::trimean::Trimean;
use crate::db::val::number::Sort;
use crate::db::val::{Number, TryPow, Value};

pub(crate) fn abs((arg,): (Number,)) -> Result<Value> {
	let Some(x) = arg.checked_abs() else {
		bail!(Error::ArithmeticOverflow(format!("math::abs({})", arg.to_sql())));
	};
	Ok(x.into())
}

pub(crate) fn acos((arg,): (Number,)) -> Result<Value> {
	Ok(arg.acos().into())
}

pub(crate) fn acot((arg,): (Number,)) -> Result<Value> {
	Ok(arg.acot().into())
}

pub(crate) fn asin((arg,): (Number,)) -> Result<Value> {
	Ok(arg.asin().into())
}

pub(crate) fn atan((arg,): (Number,)) -> Result<Value> {
	Ok(arg.atan().into())
}

pub(crate) fn bottom((array, c): (Vec<Number>, i64)) -> Result<Value> {
	ensure!(
		c > 0,
		Error::InvalidFunctionArguments {
			name: String::from("math::bottom"),
			message: String::from("The second argument must be an integer greater than 0."),
		}
	);
	Ok(array.bottom(c).into_iter().map(Value::from).collect::<Vec<_>>().into())
}

pub(crate) fn ceil((arg,): (Number,)) -> Result<Value> {
	Ok(arg.ceil().into())
}

pub(crate) fn clamp((arg, min, max): (Number, Number, Number)) -> Result<Value> {
	ensure!(
		min <= max,
		Error::InvalidFunctionArguments {
			name: "math::clamp".to_string(),
			message: "Lowerbound for clamp must be smaller than the upperbound".to_string(),
		}
	);
	Ok(arg.clamp(min, max).into())
}

pub(crate) fn cos((arg,): (Number,)) -> Result<Value> {
	Ok(arg.cos().into())
}
pub(crate) fn cot((arg,): (Number,)) -> Result<Value> {
	Ok(arg.cot().into())
}

pub(crate) fn deg2rad((arg,): (Number,)) -> Result<Value> {
	Ok(arg.deg2rad().into())
}

pub(crate) fn fixed((arg, p): (Number, i64)) -> Result<Value> {
	ensure!(
		p > 0,
		Error::InvalidFunctionArguments {
			name: String::from("math::fixed"),
			message: String::from("The second argument must be an integer greater than 0."),
		}
	);
	Ok(arg.fixed(p as usize).into())
}

pub(crate) fn floor((arg,): (Number,)) -> Result<Value> {
	Ok(arg.floor().into())
}

pub(crate) fn interquartile((mut array,): (Vec<Number>,)) -> Result<Value> {
	Ok(array.sorted().interquartile().into())
}

pub(crate) fn lerp((from, to, factor): (Number, Number, Number)) -> Result<Value> {
	Ok(factor.lerp(from, to).into())
}

pub(crate) fn lerpangle((from, to, factor): (Number, Number, Number)) -> Result<Value> {
	Ok(factor.lerp_angle(from, to).into())
}

pub(crate) fn ln((arg,): (Number,)) -> Result<Value> {
	Ok(arg.ln().into())
}

pub(crate) fn log((arg, base): (Number, Number)) -> Result<Value> {
	Ok(arg.log(base).into())
}

pub(crate) fn log10((arg,): (Number,)) -> Result<Value> {
	Ok(arg.log10().into())
}

pub(crate) fn log2((arg,): (Number,)) -> Result<Value> {
	Ok(arg.log2().into())
}

pub(crate) fn max((array,): (Vec<Number>,)) -> Result<Value> {
	Ok(match array.into_iter().max() {
		Some(v) => v.into(),
		None => f64::NEG_INFINITY.into(),
	})
}

pub(crate) fn mean((array,): (Vec<Number>,)) -> Result<Value> {
	util::math::mean(&array).map(Value::Number)
}

pub(crate) fn median((mut array,): (Vec<Number>,)) -> Result<Value> {
	Ok(if array.is_empty() {
		Value::None
	} else {
		array.sorted().median().into()
	})
}

pub(crate) fn midhinge((mut array,): (Vec<Number>,)) -> Result<Value> {
	Ok(array.sorted().midhinge().into())
}

pub(crate) fn min((array,): (Vec<Number>,)) -> Result<Value> {
	Ok(match array.into_iter().min() {
		Some(v) => v.into(),
		None => f64::INFINITY.into(),
	})
}

pub(crate) fn mode((array,): (Vec<Number>,)) -> Result<Value> {
	Ok(array.mode().into())
}

pub(crate) fn nearestrank((mut array, n): (Vec<Number>, Number)) -> Result<Value> {
	Ok(array.sorted().nearestrank(n).into())
}

pub(crate) fn percentile((mut array, n): (Vec<Number>, Number)) -> Result<Value> {
	Ok(array.sorted().percentile(n).into())
}

pub(crate) fn pow((arg, pow): (Number, Number)) -> Result<Value> {
	Ok(arg.try_pow(pow)?.into())
}

pub(crate) fn product((array,): (Vec<Number>,)) -> Result<Value> {
	Ok(array.into_iter().product::<Number>().into())
}

pub(crate) fn rad2deg((arg,): (Number,)) -> Result<Value> {
	Ok(arg.rad2deg().into())
}

pub(crate) fn round((arg,): (Number,)) -> Result<Value> {
	Ok(arg.round().into())
}

pub(crate) fn sign((arg,): (Number,)) -> Result<Value> {
	Ok(arg.sign().into())
}

pub(crate) fn sin((arg,): (Number,)) -> Result<Value> {
	Ok(arg.sin().into())
}

pub(crate) fn spread((array,): (Vec<Number>,)) -> Result<Value> {
	Ok(array.spread().into())
}

pub(crate) fn sqrt((arg,): (Number,)) -> Result<Value> {
	if arg >= Number::Int(0) {
		Ok(arg.sqrt().into())
	} else {
		Ok(f64::NAN.into())
	}
}

pub(crate) fn stddev((array,): (Vec<Number>,)) -> Result<Value> {
	util::math::deviation(&array).map(Value::Number)
}

pub(crate) fn sum((array,): (Vec<Number>,)) -> Result<Value> {
	Ok(array.into_iter().sum::<Number>().into())
}
pub(crate) fn tan((arg,): (Number,)) -> Result<Value> {
	Ok(arg.tan().into())
}

pub(crate) fn top((array, c): (Vec<Number>, i64)) -> Result<Value> {
	ensure!(
		c > 0,
		Error::InvalidFunctionArguments {
			name: String::from("math::top"),
			message: String::from("The second argument must be an integer greater than 0."),
		}
	);
	Ok(array.top(c).into_iter().map(Value::from).collect::<Vec<_>>().into())
}

pub(crate) fn trimean((mut array,): (Vec<Number>,)) -> Result<Value> {
	Ok(array.sorted().trimean().into())
}

pub(crate) fn variance((array,): (Vec<Number>,)) -> Result<Value> {
	util::math::variance(&array).map(Value::Number)
}
