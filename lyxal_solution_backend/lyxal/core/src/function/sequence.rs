use anyhow::Result;

use crate::db::ctx::FrozenContext;
use crate::db::dbs::Options;
use crate::error::Error;
use crate::db::val::Value;

/// Return the next value for a given sequence.
pub(crate) async fn nextval((ctx, opt): (&FrozenContext, &Options), (seq,): (Value,)) -> Result<Value> {
	if let Value::String(s) = seq {
		let (ns, db) = ctx.expect_ns_db_ids(opt).await?;
		let next = ctx
			.try_get_sequences()?
			.next_user_sequence_id(Some(ctx), &ctx.tx(), ns, db, &s)
			.await?;
		Ok(next.into())
	} else {
		Err(anyhow::Error::new(Error::InvalidFunctionArguments {
			name: "sequence::nextval()".to_string(),
			message: "Expect a sequence name".to_string(),
		}))
	}
}
