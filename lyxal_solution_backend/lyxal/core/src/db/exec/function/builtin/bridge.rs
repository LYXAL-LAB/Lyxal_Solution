//! Bridge functions for the streaming executor.

use anyhow::Result;

use crate::db::exec::function::FunctionRegistry;
use crate::db::exec::physical_expr::EvalContext;
use crate::db::val::Value;
use crate::{define_async_function, register_functions};

async fn bridge_call_impl(_ctx: &EvalContext<'_>, args: Vec<Value>) -> Result<Value> {
    let _provider = match args.first() {
        Some(Value::String(s)) => s.clone(),
        _ => return Err(anyhow::anyhow!("bridge::call: missing provider name")),
    };
    let _operation = match args.get(1) {
        Some(Value::String(s)) => s.clone(),
        _ => return Err(anyhow::anyhow!("bridge::call: missing operation name")),
    };
    let _params = args.get(2).cloned().unwrap_or(Value::None);

    // TODO: Wire to lyxal_bridge::bridge_call()
    tracing::warn!("bridge::call — streaming executor stub");
    Ok(Value::None)
}

async fn bridge_list_impl(_ctx: &EvalContext<'_>) -> Result<Value> {
    tracing::warn!("bridge::list — streaming executor stub");
    Ok(Value::Array(Default::default()))
}

async fn bridge_info_impl(_ctx: &EvalContext<'_>, _args: Vec<Value>) -> Result<Value> {
    tracing::warn!("bridge::info — streaming executor stub");
    Ok(Value::None)
}

async fn bridge_health_impl(_ctx: &EvalContext<'_>, _args: Vec<Value>) -> Result<Value> {
    tracing::warn!("bridge::health — streaming executor stub");
    Ok(Value::None)
}

async fn bridge_batch_impl(_ctx: &EvalContext<'_>, _args: Vec<Value>) -> Result<Value> {
    tracing::warn!("bridge::batch — streaming executor stub");
    Ok(Value::Array(Default::default()))
}

define_async_function!(BridgeCall, "bridge::call", (provider: String, operation: String, ?params: Object) -> Any, bridge_call_impl);
define_async_function!(BridgeList, "bridge::list", () -> Any, bridge_list_impl);
define_async_function!(BridgeInfo, "bridge::info", (provider: String) -> Any, bridge_info_impl);
define_async_function!(BridgeHealth, "bridge::health", (provider: String) -> Any, bridge_health_impl);
define_async_function!(BridgeBatch, "bridge::batch", (calls: Any) -> Any, bridge_batch_impl);

pub fn register(registry: &mut FunctionRegistry) {
    register_functions!(registry, BridgeCall, BridgeList, BridgeInfo, BridgeHealth, BridgeBatch,);
}
