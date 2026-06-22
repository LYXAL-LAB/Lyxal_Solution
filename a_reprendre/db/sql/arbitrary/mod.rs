mod idiom;
mod parts;
mod statements;
mod utils;
use std::time;

use arbitrary::{Arbitrary, Result, Unstructured};
pub(crate) use idiom::*;
pub(crate) use parts::*;
use rust_decimal::Decimal;
use lyxal_types_core::Duration;
pub(crate) use utils::*;

use crate::lyxal_core_db::sql::changefeed::ChangeFeed;
use crate::lyxal_core_db::sql::statements::SleepStatement;
use crate::lyxal_core_db::val::Bytes;

impl<'a> Arbitrary<'a> for ChangeFeed {
	fn arbitrary(u: &mut Unstructured<'a>) -> Result<Self> {
		Ok(Self {
			expiry: u.arbitrary()?,
			store_diff: bool::arbitrary(u)?,
		})
	}
}

impl<'a> Arbitrary<'a> for SleepStatement {
	fn arbitrary(_u: &mut Unstructured<'a>) -> Result<Self> {
		Ok(Self {
			// When fuzzing we don't want to sleep, that's slow... we want insomnia.
			duration: Duration::from_std(time::Duration::new(0, 0)),
		})
	}
}

impl<'a> Arbitrary<'a> for Bytes {
	fn arbitrary(u: &mut Unstructured<'a>) -> Result<Self> {
		Ok(Bytes(::bytes::Bytes::copy_from_slice(u.arbitrary()?)))
	}
}

pub fn arb_decimal<'a>(u: &mut Unstructured<'a>) -> Result<Decimal> {
	Ok(Decimal::arbitrary(u)?.normalize())
}
