//! REMOVE WEBHOOK statement

use anyhow::Result;
use reblessive::tree::Stk;
use std::fmt::{self, Display};

use crate::ctx::FrozenContext;
use crate::dbs::Options;
use crate::doc::CursorDoc;
use crate::expr::parameterize::expr_to_ident;
use crate::expr::Expr;
use crate::iam::{Action, ResourceKind};
use crate::key::database::wh::Wh;
use crate::val::Value;
use crate::catalog::providers::{NamespaceProvider, DatabaseProvider};

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct RemoveWebhookStatement {
    pub name: Expr,
    pub if_exists: bool,
}

impl RemoveWebhookStatement {
    /// Process this type returning a computed simple Value
    pub(crate) async fn compute(
        &self,
        stk: &mut Stk,
        ctx: &FrozenContext,
        opt: &Options,
        doc: Option<&CursorDoc>,
    ) -> Result<Value> {
        // Allowed to run?
        opt.is_allowed(Action::Edit, ResourceKind::Any, &opt.selected_base()?)?;

        // Evaluate the name expression
        let name = expr_to_ident(stk, ctx, opt, doc, &self.name, "webhook name").await?;

        // Define the namespace and database
        let (ns_name, db_name) = opt.ns_db()?;

        // Get the transaction
        let txn = ctx.tx();

        let ns = txn.expect_ns_by_name(ns_name).await?;
        let db = txn.expect_db_by_name(ns_name, db_name).await?;

        // Define the key
        let key = Wh::new(ns.namespace_id, db.database_id, &name);

        // Check if the definition exists
        if !txn.exists(&key, None).await? {
            if self.if_exists {
                return Ok(Value::None);
            }
            return Err(anyhow::anyhow!("Webhook {name} not found"));
        }

        // Delete the definition
        txn.del(&key).await?;

        // Emit event
        tracing::info!(
            event = "webhook:removed",
            name = %name,
            ns = %ns.name,
            db = %db.name,
            "Webhook removed"
        );

        // Return the result
        Ok(Value::None)
    }
}

impl Display for RemoveWebhookStatement {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "REMOVE WEBHOOK")?;
        if self.if_exists {
            write!(f, " IF EXISTS")?;
        }
        write!(f, " {:?}", self.name)
    }
}
