//! Vector functions

use anyhow::Result;

use crate::db::exec::ContextLevel;
use crate::db::exec::function::index::{IndexContext, IndexContextKind, IndexFunction};
use crate::db::exec::function::{FunctionRegistry, Signature};
use crate::db::exec::physical_expr::EvalContext;
use crate::db::expr::Kind;
use crate::db::val::Value;
use crate::{define_pure_function, register_functions};

// Single vector argument functions
define_pure_function!(VectorMagnitude, "vector::magnitude", (vector: Any) -> Float, crate::function::vector::magnitude);
define_pure_function!(VectorNormalize, "vector::normalize", (vector: Any) -> Any, crate::function::vector::normalize);

// Two vector argument functions
define_pure_function!(VectorAdd, "vector::add", (a: Any, b: Any) -> Any, crate::function::vector::add);
define_pure_function!(VectorAngle, "vector::angle", (a: Any, b: Any) -> Float, crate::function::vector::angle);
define_pure_function!(VectorCross, "vector::cross", (a: Any, b: Any) -> Any, crate::function::vector::cross);
define_pure_function!(VectorDivide, "vector::divide", (a: Any, b: Any) -> Any, crate::function::vector::divide);
define_pure_function!(VectorDot, "vector::dot", (a: Any, b: Any) -> Float, crate::function::vector::dot);
define_pure_function!(VectorMultiply, "vector::multiply", (a: Any, b: Any) -> Any, crate::function::vector::multiply);
define_pure_function!(VectorProject, "vector::project", (a: Any, b: Any) -> Any, crate::function::vector::project);
define_pure_function!(VectorSubtract, "vector::subtract", (a: Any, b: Any) -> Any, crate::function::vector::subtract);

// Vector with scalar
define_pure_function!(VectorScale, "vector::scale", (vector: Any, scalar: Number) -> Any, crate::function::vector::scale);

// Distance functions
define_pure_function!(VectorDistanceChebyshev, "vector::distance::chebyshev", (a: Any, b: Any) -> Float, crate::function::vector::distance::chebyshev);
define_pure_function!(VectorDistanceEuclidean, "vector::distance::euclidean", (a: Any, b: Any) -> Float, crate::function::vector::distance::euclidean);
define_pure_function!(VectorDistanceHamming, "vector::distance::hamming", (a: Any, b: Any) -> Float, crate::function::vector::distance::hamming);
define_pure_function!(VectorDistanceMahalanobis, "vector::distance::mahalanobis", (a: Any, b: Any, cov: Any) -> Float, crate::function::vector::distance::mahalanobis);
define_pure_function!(VectorDistanceManhattan, "vector::distance::manhattan", (a: Any, b: Any) -> Float, crate::function::vector::distance::manhattan);
define_pure_function!(VectorDistanceMinkowski, "vector::distance::minkowski", (a: Any, b: Any, p: Number) -> Float, crate::function::vector::distance::minkowski);

// Similarity functions
define_pure_function!(VectorSimilarityCosine, "vector::similarity::cosine", (a: Any, b: Any) -> Float, crate::function::vector::similarity::cosine);
define_pure_function!(VectorSimilarityJaccard, "vector::similarity::jaccard", (a: Any, b: Any) -> Float, crate::function::vector::similarity::jaccard);
define_pure_function!(VectorSimilarityPearson, "vector::similarity::pearson", (a: Any, b: Any) -> Float, crate::function::vector::similarity::pearson);
define_pure_function!(VectorSimilaritySpearman, "vector::similarity::spearman", (a: Any, b: Any) -> Float, crate::function::vector::similarity::spearman);

// =========================================================================
// vector::distance::knn - IndexFunction (reads distance from KNN context)
// =========================================================================

/// Returns the KNN distance for the current row, as computed by the KNN scan
/// operator (e.g., HNSW index search).
///
/// Usage: `SELECT id, vector::distance::knn() AS dist FROM pts WHERE point <|2,100|> $pt`
///
/// This is an [`IndexFunction`] with [`IndexContextKind::Knn`]. The distance
/// is populated by the KNN scan operator at execution time and looked up by
/// RecordId from the shared [`KnnContext`].
#[derive(Debug, Clone, Copy, Default)]
pub struct VectorDistanceKnn;

impl IndexFunction for VectorDistanceKnn {
	fn name(&self) -> &'static str {
		"vector::distance::knn"
	}

	fn signature(&self) -> Signature {
		Signature::new().optional("knn_ref", Kind::Number).returns(Kind::Any)
	}

	fn index_context_kind(&self) -> IndexContextKind {
		IndexContextKind::Knn
	}

	fn index_ref_arg_index(&self) -> Option<usize> {
		// First argument is the optional KNN reference number, extracted at plan time
		Some(0)
	}

	fn required_context(&self) -> ContextLevel {
		ContextLevel::Root
	}

	fn invoke_async<'a>(
		&'a self,
		ctx: &'a EvalContext<'_>,
		index_ctx: &'a IndexContext,
		_args: Vec<Value>,
	) -> crate::db::exec::BoxFut<'a, Result<Value>> {
		Box::pin(async move {
			let knn_ctx = match index_ctx {
				IndexContext::Knn(ctx) => ctx,
				_ => {
					return Err(anyhow::anyhow!(
						"vector::distance::knn requires a KNN index context"
					));
				}
			};

			// Extract RecordId from the current row
			let rid = extract_record_id(ctx)?;

			// Look up the precomputed distance for this record
			match knn_ctx.get(&rid).await {
				Some(dist) => Ok(Value::Number(dist)),
				None => Ok(Value::None),
			}
		})
	}
}

/// Extract the RecordId from the current row value.
fn extract_record_id(ctx: &EvalContext<'_>) -> Result<crate::db::val::RecordId> {
	let current = ctx.current_value.ok_or_else(|| {
		anyhow::anyhow!(
			"vector::distance::knn requires a current document (must be used in SELECT)"
		)
	})?;

	match current {
		Value::Object(obj) => match obj.get("id") {
			Some(Value::RecordId(rid)) => Ok(rid.clone()),
			Some(_) => Err(anyhow::anyhow!("Current document 'id' field is not a RecordId")),
			None => Err(anyhow::anyhow!("Current document has no 'id' field")),
		},
		Value::RecordId(rid) => Ok(rid.clone()),
		_ => Err(anyhow::anyhow!(
			"Expected current document to be an Object, got: {}",
			current.kind_of()
		)),
	}
}

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(
		registry,
		VectorAdd,
		VectorAngle,
		VectorCross,
		VectorDistanceChebyshev,
		VectorDistanceEuclidean,
		VectorDistanceHamming,
		VectorDistanceMahalanobis,
		VectorDistanceManhattan,
		VectorDistanceMinkowski,
		VectorDivide,
		VectorDot,
		VectorMagnitude,
		VectorMultiply,
		VectorNormalize,
		VectorProject,
		VectorScale,
		VectorSimilarityCosine,
		VectorSimilarityJaccard,
		VectorSimilarityPearson,
		VectorSimilaritySpearman,
		VectorSubtract,
	);

	// Index function (reads distance from KNN context)
	registry.register_index_function(VectorDistanceKnn);
}
