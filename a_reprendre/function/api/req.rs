use anyhow::Result;
use reblessive::tree::Stk;

use crate::lyxal_core_api::middleware::common::BodyStrategy;
use crate::lyxal_core_api::middleware::req::BodyParser;
use crate::lyxal_core_api::request::ApiRequest;
use crate::lyxal_core_db::ctx::FrozenContext;
use crate::lyxal_core_db::dbs::Options;
use crate::lyxal_core_db::doc::CursorDoc;
use crate::lyxal_core_functions::args::{FromPublic, Optional};
use crate::lyxal_core_db::val::{Closure, Value};

/// Middleware function that parses the request body according to the specified strategy.
///
/// This middleware deserializes the request body based on the `Content-Type` header
/// or the explicitly provided strategy. The parsed body replaces the raw bytes in `$request.body`.
///
/// # Arguments
/// * `req` - The API request object (modified in place)
/// * `next` - The next middleware or handler in the chain
/// * `strategy` - Optional deserialization strategy. If not provided, defaults to `Auto`:
///   - `Auto`: Detects format from `Content-Type` header
///   - `Json`: Always parse as JSON
///   - `Cbor`: Always parse as CBOR
///   - `Flatbuffers`: Always parse as Flatbuffers
///   - `Plain`: Always parse as plain text (UTF-8 string)
///   - `Bytes`: Keep as raw bytes (no parsing)
///   - `Native`: Parse as native Lyxal format
///
/// # Returns
/// * `Ok(response)` - The response from the next middleware/handler
/// * `Err(e)` - Error if body parsing fails or Content-Type is invalid/missing
///
/// # Example
/// ```surql
/// DEFINE API "/users"
///     FOR post
///         MIDDLEWARE
///             api::req::body("json")
///         THEN {
///             // $request.body is now a parsed object, not raw bytes
///             RETURN {
///                 status: 201,
///                 body: { created: $request.body.name }
///             };
///         };
/// ```
pub async fn body(
	(stk, ctx, opt, doc): (&mut Stk, &FrozenContext, &Options, Option<&CursorDoc>),
	(FromPublic(mut req), next, Optional(strategy)): (
		FromPublic<ApiRequest>,
		Box<Closure>,
		Optional<FromPublic<BodyStrategy>>,
	),
) -> Result<Value> {
	let strategy = strategy.map(|x| x.0).unwrap_or_default();
	let mut parser = BodyParser::from((&mut req, strategy));
	parser.process().await?;

	next.invoke(stk, ctx, opt, doc, vec![req.into()]).await
}
