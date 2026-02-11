use anyhow::Result;
use reblessive::tree::Stk;

use crate::ctx::FrozenContext;
use crate::dbs::Options;
use crate::doc::CursorDoc;
use crate::expr::parameterize::expr_to_ident;
use crate::expr::Expr;
use crate::iam::{Action, ResourceKind};
use crate::key::database::sd::Sd;
use crate::val::Value;
use crate::catalog::providers::{NamespaceProvider, DatabaseProvider};
use crate::dbs::SystemEvent;

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct RemoveSchedulerStatement {
	pub name: Expr,
	pub if_exists: bool,
}

impl RemoveSchedulerStatement {
	/// Process this type returning a computed simple Value
	pub(crate) async fn compute(
		&self,
		stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		doc: Option<&CursorDoc>,
	) -> Result<Value> {
		// Allowed to run?
		opt.is_allowed(Action::Edit, ResourceKind::Scheduler, &opt.selected_base()?)?;
		
		// Evaluate the name expression
		let name = expr_to_ident(stk, ctx, opt, doc, &self.name, "scheduler name").await?;
		
		// Define the namespace and database
		let (ns_name, db_name) = opt.ns_db()?;
		
		// Get the transaction
		let txn = ctx.tx();

		let ns = txn.expect_ns_by_name(ns_name).await?;
		let db = txn.expect_db_by_name(ns_name, db_name).await?;
		
		// Define the key
		let key = Sd::new(ns.namespace_id, db.database_id, &name);
		
		// Check if the definition exists
		if !txn.exists(&key, None).await? {
			if self.if_exists {
				return Ok(Value::None);
			}
			return Err(anyhow::anyhow!("Scheduler {name} not found"));
		}
		
		// Delete the definition
		txn.del(&key).await?;

		// Emit system event
		txn.record_system_event(SystemEvent::SchedulerRemoved {
			ns: ns.name.to_string(),
			db: db.name.to_string(),
			name: name.to_string(),
		});

		// Return the result
		Ok(Value::None)
	}
}

