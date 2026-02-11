//! REMOVE CREDENTIAL statement

use std::fmt::{self, Display};

use anyhow::{Result, bail};
use reblessive::tree::Stk;

use crate::catalog::providers::{DatabaseProvider, NamespaceProvider};
use crate::ctx::FrozenContext;
use crate::dbs::Options;
use crate::doc::CursorDoc;
use crate::err::Error;
use crate::expr::{Base, Expr, FlowResultExt as _};
use crate::iam::{Action, ResourceKind};
use crate::val::Value;

/// REMOVE CREDENTIAL statement
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct RemoveCredentialStatement {
    pub name: Expr,
    pub if_exists: bool,
}

impl RemoveCredentialStatement {
    /// Process this type returning a computed simple Value
    #[instrument(level = "trace", name = "RemoveCredentialStatement::compute", skip_all)]
    pub(crate) async fn compute(
        &self,
        stk: &mut Stk,
        ctx: &FrozenContext,
        opt: &Options,
        _doc: Option<&CursorDoc>,
    ) -> Result<Value> {
        // Allowed to run?
        opt.is_allowed(Action::Edit, ResourceKind::Parameter, &Base::Db)?;

        // Get credential name
        let name: String = stk
            .run(|stk| self.name.compute(stk, ctx, opt, None))
            .await
            .catch_return()?
            .cast_to()?;

        // Fetch the transaction
        let txn = ctx.tx();

        // Check namespace and database
        let (ns_id, db_id) = ctx.get_ns_db_ids(opt).await?;
        let _ns = txn.expect_ns_by_name(opt.ns()?).await?;
        let _db = txn.expect_db_by_name(opt.ns()?, opt.db()?).await?;

        // Check if the credential exists
        match txn.get_db_credential(ns_id, db_id, &name).await {
            Ok(_) => {
                // Delete the credential
                txn.del_db_credential(ns_id, db_id, &name).await?;

                // Emit system event
                tracing::info!(
                    target: "surrealdb::credential",
                    credential = %name,
                    "credential:removed"
                );
            }
            Err(_) if self.if_exists => {
                // IF EXISTS was specified and credential doesn't exist, silently succeed
                return Ok(Value::None);
            }
            Err(_) => {
                bail!(Error::CrNotFound {
                    name: name.clone(),
                });
            }
        }

        // Clear the cache
        txn.clear_cache();

        Ok(Value::None)
    }
}

impl Display for RemoveCredentialStatement {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "REMOVE CREDENTIAL")?;
        if self.if_exists {
            write!(f, " IF EXISTS")?;
        }
        write!(f, " {:?}", self.name)?;
        Ok(())
    }
}
