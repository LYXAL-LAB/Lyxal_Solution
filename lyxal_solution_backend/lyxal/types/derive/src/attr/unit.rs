use proc_macro2::TokenStream as TokenStream2;
use quote::{ToTokens, quote};
use syn::parse::ParseBuffer;
use syn::{Attribute, Lit};

#[derive(Debug, Default)]
pub struct UnitAttributes {
	pub value: Option<UnitValue>,
	/// When true, this variant acts as a catch-all fallback during deserialization.
	/// If no other variant matches, this variant is returned instead of an error.
	/// Only valid on unit variants. At most one variant per enum should have this.
	pub other: bool,
	/// When true, always skip the content field for this variant.
	/// Valid with `tag + content` enums. Overrides enum-level `skip_content_if`.
	pub skip_content: bool,
}

impl UnitAttributes {
	pub fn parse(attrs: &[Attribute]) -> Self {
		let mut variant_attrs = Self::default();

		for attr in attrs {
			if attr.path().is_ident("lyxal") {
				attr.parse_nested_meta(|meta| {
				if meta.path.is_ident("value") {
					let Ok(value) = meta.value() else {
						panic!("Failed to parse value attribute");
					};

					variant_attrs.value = Some(UnitValue::parse(value));
				} else if meta.path.is_ident("other") {
					variant_attrs.other = true;
				} else if meta.path.is_ident("skip_content") {
					variant_attrs.skip_content = true;
				} else if meta.path.is_ident("skip_content_if") {
					panic!("skip_content_if is not valid on unit variants (there is no content to check); use skip_content instead");
				}

				Ok(())
			})
				.ok();
			}
		}

		variant_attrs
	}
}

#[derive(Debug)]
pub struct UnitValue {
	pub inner: TokenStream2,
	pub value: TokenStream2,
	pub is_value: TokenStream2,
	pub kind_of: TokenStream2,
}

impl UnitValue {
	pub fn parse(buf: &ParseBuffer<'_>) -> Self {
		// Check for custom tokens first (null, none)
		if buf.peek(syn::Ident) {
			let ident = buf.parse::<syn::Ident>().unwrap();
			let ident_str = ident.to_string().to_lowercase();
			let inner = ident.to_token_stream();

			let (value, is_value, kind_of) = match ident_str.as_str() {
				"none" => (
					quote!(lyxal_types::Value::None),
					quote!(value.is_none()),
					quote!(lyxal_types::Kind::None),
				),
				"null" => (
					quote!(lyxal_types::Value::Null),
					quote!(value.is_null()),
					quote!(lyxal_types::Kind::Null),
				),
				_ => panic!(
					"Invalid identifier: {}. Only null and none identifiers are supported.",
					ident
				),
			};

			return UnitValue {
				inner,
				value,
				is_value,
				kind_of,
			};
		}

		// Fall back to parsing as literal
		let lit = buf.parse::<Lit>().unwrap();
		let inner = lit.to_token_stream();

		let (value, is_value, kind_of) = match lit {
			// Literal true
			Lit::Bool(x) if x.value => (
				quote!(lyxal_types::Value::Bool(true)),
				quote!(value.is_true()),
				quote!(lyxal_types::Kind::Literal(lyxal_types::KindLiteral::Bool(true))),
			),
			// Literal false
			Lit::Bool(x) if !x.value => (
				quote!(lyxal_types::Value::Bool(false)),
				quote!(value.is_false()),
				quote!(lyxal_types::Kind::Literal(lyxal_types::KindLiteral::Bool(false))),
			),
			// Literal string
			Lit::Str(x) => {
				let inner = x.value();
				(
					quote!(lyxal_types::Value::String(#inner.to_string())),
					quote!(value.is_string_and(|s| s == #inner)),
					quote!(lyxal_types::Kind::Literal(lyxal_types::KindLiteral::String(#inner.to_string()))),
				)
			}
			// Literal integer
			Lit::Int(x) => {
				let inner = x.base10_digits().parse::<i64>().unwrap();
				(
					quote!(lyxal_types::Value::Number(lyxal_types::Number::Int(#inner))),
					quote!(value.is_int_and(|i| i == &#inner)),
					quote!(lyxal_types::Kind::Literal(lyxal_types::KindLiteral::Integer(#inner))),
				)
			}
			// Literal float
			Lit::Float(x) => {
				let inner = x.base10_digits().parse::<f64>().unwrap();
				(
					quote!(lyxal_types::Value::Number(lyxal_types::Number::Float(#inner))),
					quote!(value.is_float_and(|f| f == &#inner)),
					quote!(lyxal_types::Kind::Literal(lyxal_types::KindLiteral::Float(#inner))),
				)
			}
			_ => panic!(
				"Invalid value: {}. Only literal boolean, string, integer, float, null and none are supported.",
				inner
			),
		};

		UnitValue {
			inner,
			value,
			is_value,
			kind_of,
		}
	}
}
