use anyhow::Result;
use crate::ctx::FrozenContext;
use crate::dbs::Options;
use crate::doc::CursorDoc;
use crate::expr::{Expr, Base, FlowResultExt};
use crate::iam::{Action, ResourceKind};
use crate::key::database::sd::Sd;
use crate::catalog::SchedulerDefinition;
use crate::sql::scheduler_bootstrap::ensure_bootstrap; // Import bootstrap
use crate::val::Value;
use reblessive::tree::Stk;
use std::fmt::{self, Display};
use crate::dbs::SystemEvent;
use crate::expr::parameterize::expr_to_ident;
use crate::catalog::providers::{NamespaceProvider, DatabaseProvider};

use crate::expr::statements::define::DefineKind;

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct DefineSchedulerStatement {
	pub kind: DefineKind,
	pub name: Expr,
	pub base: Base,
	pub enabled: bool,
	pub action: Expr,
	pub comment: Option<Expr>,
}

impl DefineSchedulerStatement {
	/// Process this type returning a computed simple Value
	pub(crate) async fn compute(
		&self,
		stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		doc: Option<&CursorDoc>,
	) -> Result<Value> {
		// Ensure bootstrap schema exists
		ensure_bootstrap(stk, ctx, opt).await.map_err(|e| e)?;

		// Evaluate the name expression
		let name = expr_to_ident(stk, ctx, opt, doc, &self.name, "scheduler name").await?;
		
		// Define the namespace and database
		let (ns_name, db_name) = opt.ns_db()?;
        
        // Get the transaction
		let txn = ctx.tx();

        let ns = txn.expect_ns_by_name(ns_name).await?;
        let db = txn.expect_db_by_name(ns_name, db_name).await?;
		
		// Check the user permissions
		match self.base {
			Base::Root => opt.is_allowed(Action::Edit, ResourceKind::Scheduler, &Base::Root)?,
			Base::Ns => opt.is_allowed(Action::Edit, ResourceKind::Scheduler, &Base::Ns)?,
			Base::Db => opt.is_allowed(Action::Edit, ResourceKind::Scheduler, &Base::Db)?,
		}
		
		// Define the key
		let key = Sd::new(ns.namespace_id, db.database_id, &name);
		
		// Check if the definition exists
		if let DefineKind::IfNotExists = self.kind {
			if txn.exists(&key, None).await? {
				return Ok(Value::None);
			}
		}

		// Evaluate action
		let action = stk.run(|stk| self.action.compute(stk, ctx, opt, doc)).await.catch_return()?.to_raw_string();
		
		// Evaluate comment if present
		let comment = if let Some(ref c) = self.comment {
            let v = stk.run(|stk| c.compute(stk, ctx, opt, doc)).await.catch_return()?;
			Some(v.to_raw_string())
		} else {
			None
		};

		// Create the definition
		let val = SchedulerDefinition {
			name: name.to_owned(),
			enabled: self.enabled,
			action,
			comment,
			created_at: crate::dbs::node::Timestamp::default(),
		};
		
		// Set the definition
		txn.set(&key, &val, None).await?;

		// Emit system event
		txn.record_system_event(SystemEvent::SchedulerDefined {
			ns: ns.name.to_string(),
			db: db.name.to_string(),
			name: name.to_string(),
			enabled: self.enabled,
		});

		// Return the result
		Ok(Value::None)
	}
}

impl Display for DefineSchedulerStatement {
	fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
		write!(f, "DEFINE SCHEDULER")?;
		if self.kind != DefineKind::Default {
			write!(f, " {}", match self.kind {
				DefineKind::Default => "",
				DefineKind::Overwrite => "OVERWRITE",
				DefineKind::IfNotExists => "IF NOT EXISTS",
			})?;
		}
		write!(f, " {:?}", self.name)?;
		write!(f, " ON {}", self.base)?;
		write!(f, " ACTION {:?}", self.action)?;
		if !self.enabled {
			write!(f, " DISABLED")?;
		}
		if let Some(ref v) = self.comment {
			write!(f, " COMMENT {:?}", v)?;
		}
		Ok(())
	}
}

impl From<crate::sql::statements::define::DefineSchedulerStatement> for DefineSchedulerStatement {
	fn from(v: crate::sql::statements::define::DefineSchedulerStatement) -> Self {
		Self {
			kind: v.kind.into(),
			name: v.name.into(),
			base: v.base.into(),
			enabled: v.enabled,
			action: v.action.into(),
			comment: match v.comment {
				crate::sql::Expr::Literal(crate::sql::Literal::None) => None,
				e => Some(e.into()),
			},
		}
	}
}

impl From<DefineSchedulerStatement> for crate::sql::statements::define::DefineSchedulerStatement {
	fn from(v: DefineSchedulerStatement) -> Self {
		Self {
			kind: v.kind.into(),
			name: v.name.into(),
			base: v.base.into(),
			enabled: v.enabled,
			action: v.action.into(),
			comment: v.comment.unwrap_or(Expr::Literal(crate::expr::Literal::None)).into(),
		}
	}
}
