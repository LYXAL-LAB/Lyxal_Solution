//! Defines the session module for the execution module.
#[cfg(feature = "gpu")]
use ort::execution_providers::CUDAExecutionProvider;
#[cfg(feature = "gpu")]
use ort::execution_providers::ExecutionProvider;
use ort::session::Session;

use crate::errors::error::{LyxalError, LyxalErrorStatus};
use crate::safe_eject;

/// Creates a session for a model.
///
/// # Arguments
/// * `model_bytes` - The model bytes (usually extracted fromt the surml file)
///
/// # Returns
/// A session object.
pub fn get_session(model_bytes: Vec<u8>) -> Result<Session, LyxalError> {
	#[cfg(feature = "gpu")]
	let mut builder = safe_eject!(Session::builder(), LyxalErrorStatus::Unknown);

	#[cfg(not(feature = "gpu"))]
	let mut builder = safe_eject!(Session::builder(), LyxalErrorStatus::Unknown);

	#[cfg(feature = "gpu")]
	{
		let cuda = CUDAExecutionProvider::default();
		if let Err(e) = cuda.register(&mut builder) {
			eprintln!("Failed to register CUDA: {:?}. Falling back to CPU.", e);
		} else {
			println!("CUDA registered successfully");
		}
	}
	let session: Session =
		safe_eject!(builder.commit_from_memory(&model_bytes), LyxalErrorStatus::Unknown);
	Ok(session)
}
