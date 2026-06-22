use reblessive::tree::Stk;

use crate::db::ctx::FrozenContext;
use crate::db::dbs::Options;
use crate::db::doc::CursorDoc;
use crate::db::expr::parameterize::expr_to_optional_ident;
use crate::db::expr::{Expr, Literal};

#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub(crate) struct DefaultConfig {
	pub namespace: Expr,
	pub database: Expr,
}

impl Default for DefaultConfig {
	fn default() -> Self {
		Self {
			namespace: Expr::Literal(Literal::None),
			database: Expr::Literal(Literal::None),
		}
	}
}

impl DefaultConfig {
	#[instrument(level = "trace", name = "DefaultConfig::compute", skip_all)]
	pub(crate) async fn compute(
		&self,
		stk: &mut Stk,
		ctx: &FrozenContext,
		opt: &Options,
		doc: Option<&CursorDoc>,
	) -> anyhow::Result<crate::db::catalog::DefaultConfig> {
		let namespace = match &self.namespace {
			Expr::Literal(Literal::None) => None,
			x => expr_to_optional_ident(stk, ctx, opt, doc, x, "namespace").await?,
		};

		let database = match &self.database {
			Expr::Literal(Literal::None) => None,
			x => expr_to_optional_ident(stk, ctx, opt, doc, x, "database").await?,
		};

		Ok(crate::db::catalog::DefaultConfig {
			namespace,
			database,
		})
	}
}
