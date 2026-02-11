//! Exports the `lyxal_revisioned` and `revisioned` procedural macro attributes, and the derive procedural
//! macro that automatically generates the LyxalRevisioned trait on structs and enums.

use proc_macro::TokenStream;

mod ast;
mod expand;

/// Generates serialization and deserialization code as an implementation of
/// the `LyxalRevisioned` trait for structs and enums.
#[proc_macro_attribute]
pub fn lyxal_revisioned(attrs: TokenStream, input: TokenStream) -> proc_macro::TokenStream {
	match expand::lyxal_revision(attrs.into(), input.into()) {
		Ok(x) => x.into(),
		Err(e) => e.into_compile_error().into(),
	}
}

/// Alias for `lyxal_revisioned`.
#[proc_macro_attribute]
pub fn revisioned(attrs: TokenStream, input: TokenStream) -> proc_macro::TokenStream {
	lyxal_revisioned(attrs, input)
}
