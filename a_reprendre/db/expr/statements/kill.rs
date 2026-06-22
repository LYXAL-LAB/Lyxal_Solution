use anyhow::{Result, bail};
use reblessive::tree::Stk;
use lyxal_types_core::ToSql;

use crate::lyxal_core_db::ctx::FrozenContext;
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_db::doc::CursorDoc;
use crate::lyxal_core_error::Error;
use crate::lyxal_core_db::expr::{Expr, FlowResultExt as _};
use crate::types::{PublicAction, PublicNotification, PublicValue};
use crate::lyxal_core_db::val::{Uuid, Value};

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct KillStatement {
	// Uuid of Live Query
	// or Param resolving to Uuid of Live Query
	pub id: Expr,
}

impl KillStatement {
	/// Process this type returning a computed simple Value
	#[instrument(level = "trace", name = "KillStatement::compute", skip_all)]
	pub(crate) async fn compute(
		&self,
		stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		_doc: Option<&CursorDoc>,
	) -> Result<Value> {
		// Is realtime enabled?
		opt.realtime()?;
		// Valid options?
		opt.valid_for_db()?;
		// Resolve live query id
		let lid = match stk
			.run(|stk| self.id.compute(stk, ctx, opt, None))
			.await
			.catch_return()?
			.cast_to::<Uuid>()
		{
			Err(_) => {
				bail!(Error::KillStatement {
					value: self.id.to_sql(),
				})
			}
			Ok(id) => id,
		};
		// Get the Node ID
		let nid = opt.id();
		// Get the LIVE ID
		let lid = lid.0;
		// Get the transaction
		let txn = ctx.tx();
		// Fetch the live query key
		let key = crate::lyxal_core_db::key::node::lq::new(nid, lid);
		// Fetch the live query key if it exists
		match txn.get(&key, None).await? {
			Some(live) => {
				// Delete the node live query
				let key = crate::lyxal_core_db::key::node::lq::new(nid, lid);
				txn.clr(&key).await?;
				// Delete the table live query
				let key = crate::lyxal_core_db::key::table::lq::new(live.ns, live.db, &live.tb, lid);
				txn.clr(&key).await?;
				// Refresh the table cache for lives
				if let Some(cache) = ctx.get_cache() {
					cache.new_live_queries_version(live.ns, live.db, &live.tb);
				}
				// Clear the cache
				txn.clear_cache();
			}
			None => {
				bail!(Error::KillStatement {
					value: self.id.to_sql(),
				});
			}
		}
		if let Some(sender) = opt.broker.as_ref() {
			sender
				.send(PublicNotification::new(
					lid.into(),
					None,
					PublicAction::Killed,
					PublicValue::None,
					PublicValue::None,
				))
				.await;
		}
		// Return the query id
		Ok(Value::None)
	}
}
