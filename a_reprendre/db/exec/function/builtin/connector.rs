//! Connector functions for calling DEFINE CONNECTOR endpoints.

use anyhow::Result;
use reblessive::TreeStack;

use crate::lyxal_core_error::Error;
use crate::lyxal_core_db::exec::function::{FunctionRegistry, ScalarFunction, Signature};
use crate::lyxal_core_db::exec::physical_expr::EvalContext;
use crate::lyxal_core_db::expr::Kind;
use crate::lyxal_core_functions::args::FromArgs;
use crate::lyxal_core_db::val::Value;

// =========================================================================
// Shared helper macro for async connector functions using TreeStack
// =========================================================================

macro_rules! connector_async_fn {
    ($struct_name:ident, $fn_name:literal, $fn_path:path, $signature:expr) => {
        #[derive(Debug, Clone, Copy, Default)]
        pub struct $struct_name;

        impl ScalarFunction for $struct_name {
            fn name(&self) -> &'static str {
                $fn_name
            }

            fn signature(&self) -> Signature {
                $signature
            }

            fn is_pure(&self) -> bool {
                false
            }

            fn is_async(&self) -> bool {
                true
            }

            fn invoke(&self, _args: Vec<Value>) -> Result<Value> {
                Err(anyhow::anyhow!(
                    "Function '{}' requires async execution",
                    self.name()
                ))
            }

            fn invoke_async<'a>(
                &'a self,
                ctx: &'a EvalContext<'_>,
                args: Vec<Value>,
            ) -> crate::lyxal_core_db::exec::BoxFut<'a, Result<Value>> {
                Box::pin(async move {
                    let frozen = ctx.exec_ctx.ctx();
                    let opt = ctx.exec_ctx.options().ok_or_else(|| {
                        anyhow::anyhow!(Error::Internal(format!(
                            "No options available for {}",
                            $fn_name
                        )))
                    })?;

                    let args = FromArgs::from_args($fn_name, args)?;

                    let mut stack = TreeStack::new();
                    stack
                        .enter(|stk| async move { $fn_path((stk, frozen, opt), args).await })
                        .finish()
                        .await
                })
            }
        }
    };
}

// =========================================================================
// connector::call - Invoke a defined connector endpoint
// =========================================================================

connector_async_fn!(
    ConnectorCall,
    "connector::call",
    crate::lyxal_core_functions::connector::call,
    Signature::new()
        .arg("connector", Kind::String)
        .arg("endpoint", Kind::String)
        .optional("params", Kind::Any)
        .returns(Kind::Any)
);

// =========================================================================
// connector::list - List all defined connectors
// =========================================================================

connector_async_fn!(
    ConnectorList,
    "connector::list",
    crate::lyxal_core_functions::connector::list,
    Signature::new().returns(Kind::Array(Box::new(Kind::Object), None))
);

// =========================================================================
// connector::info - Get detailed info about a connector
// =========================================================================

connector_async_fn!(
    ConnectorInfo,
    "connector::info",
    crate::lyxal_core_functions::connector::info,
    Signature::new()
        .arg("connector", Kind::String)
        .returns(Kind::Object)
);

// =========================================================================
// connector::health - Ping a connector's base URL
// =========================================================================

connector_async_fn!(
    ConnectorHealth,
    "connector::health",
    crate::lyxal_core_functions::connector::health,
    Signature::new()
        .arg("connector", Kind::String)
        .returns(Kind::Object)
);

// =========================================================================
// connector::batch - Call an endpoint for each item in an array
// =========================================================================

connector_async_fn!(
    ConnectorBatch,
    "connector::batch",
    crate::lyxal_core_functions::connector::batch,
    Signature::new()
        .arg("connector", Kind::String)
        .arg("endpoint", Kind::String)
        .arg("params", Kind::Array(Box::new(Kind::Any), None))
        .returns(Kind::Array(Box::new(Kind::Any), None))
);

// =========================================================================
// Registration
// =========================================================================

pub fn register(registry: &mut FunctionRegistry) {
    registry.register(ConnectorCall);
    registry.register(ConnectorList);
    registry.register(ConnectorInfo);
    registry.register(ConnectorHealth);
    registry.register(ConnectorBatch);
}