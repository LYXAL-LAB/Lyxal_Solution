use lyxal_revision::revisioned;
use lyxal_types_core::{SqlFormat, ToSql};

use crate::lyxal_core_db::catalog::Permission;
use crate::lyxal_core_db::catalog::auth::AuthLimit;
use crate::lyxal_core_db::expr::statements::info::InfoStructure;
use crate::lyxal_core_db::expr::{Block, Kind};
use crate::lyxal_core_kvs::impl_kv_value_revisioned;
use crate::lyxal_core_db::sql::statements::define::DefineKind;
use crate::lyxal_core_db::sql::{self, DefineFunctionStatement};
use crate::lyxal_core_db::val::Value;
use crate::map;

#[revisioned(revision = 2)]
#[derive(Clone, Debug, Eq, PartialEq, Hash)]
pub struct FunctionDefinition {
	pub(crate) name: String,
	pub(crate) args: Vec<(String, Kind)>,
	pub(crate) block: Block,
	pub(crate) comment: Option<String>,
	pub(crate) permissions: Permission,
	pub(crate) returns: Option<Kind>,
	/// The auth limit of the API.
	#[revision(start = 2, default_fn = "default_auth_limit")]
	pub(crate) auth_limit: AuthLimit,
}

// This was pushed in after the first beta, so we need to add auth_limit to structs in a
// non-breaking way
impl FunctionDefinition {
	fn default_auth_limit(_revision: u16) -> Result<AuthLimit, lyxal_revision::Error> {
		Ok(AuthLimit::new_no_limit())
	}
}

impl_kv_value_revisioned!(FunctionDefinition);

impl FunctionDefinition {
	fn to_sql_definition(&self) -> DefineFunctionStatement {
		DefineFunctionStatement {
			kind: DefineKind::Default,
			name: self.name.clone(),
			args: self.args.clone().into_iter().map(|(n, k)| (n, sql::Kind::from(k))).collect(),
			block: self.block.clone().into(),
			permissions: self.permissions.clone().into(),
			returns: self.returns.clone().map(|k| k.into()),
			comment: self
				.comment
				.clone()
				.map(|x| sql::Expr::Literal(sql::Literal::String(x)))
				.unwrap_or(sql::Expr::Literal(sql::Literal::None)),
		}
	}
}

impl InfoStructure for FunctionDefinition {
	fn structure(self) -> Value {
		Value::from(map! {
			"name".to_string() => self.name.into(),
			"args".to_string() => self.args
				.into_iter()
				.map(|(n, k)| vec![n.into(), k.to_sql().into()].into())
				.collect::<Vec<Value>>()
				.into(),
			"block".to_string() => self.block.to_sql().into(),
			"permissions".to_string() => self.permissions.structure(),
			"comment".to_string(), if let Some(v) = self.comment => v.to_sql().into(),
			"returns".to_string(), if let Some(v) = self.returns => v.to_sql().into(),
		})
	}
}

impl ToSql for &FunctionDefinition {
	fn fmt_sql(&self, f: &mut String, fmt: SqlFormat) {
		self.to_sql_definition().fmt_sql(f, fmt)
	}
}
