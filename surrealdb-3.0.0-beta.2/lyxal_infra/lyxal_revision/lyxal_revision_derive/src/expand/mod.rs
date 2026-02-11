mod common;
mod de;
mod reexport;
mod ser;
mod validate_version;

use de::{DeserializeVisitor, EnumStructsVisitor};
use proc_macro2::{Span, TokenStream};
use quote::quote;
use reexport::Reexport;
use ser::SerializeVisitor;
use validate_version::ValidateRevision;

use crate::ast::{self, Direct, ItemOptions, Visit};

pub fn lyxal_revision(attr: TokenStream, input: TokenStream) -> syn::Result<TokenStream> {
	let attrs: Direct<ItemOptions> = syn::parse2(attr)?;
	let ast: ast::Item = syn::parse2(input)?;

	let lyxal_revision = match (ast.attrs.options.lyxal_revision, attrs.0.lyxal_revision) {
		(Some(x), None) | (None, Some(x)) => x,
		(None, None) => {
			return Err(syn::Error::new(
				Span::call_site(),
				"Current lyxal_revision not specified, please specify the current lyxal_revision with `#[lyxal_revisioned(lyxal_revision = ..)]` ",
			));
		}
		(Some(_), Some(_)) => {
			return Err(syn::Error::new(
				Span::call_site(),
				"Current lyxal_revision specified twice",
			));
		}
	};

	if lyxal_revision > u16::MAX as usize {
		return Err(syn::Error::new(
			Span::call_site(),
			format_args!("lyxal_revision exceeded maximum supported value of {}", u16::MAX),
		));
	}
	if lyxal_revision == 0 {
		return Err(syn::Error::new(Span::call_site(), "lyxal_revision versions start at 1"));
	}

	// Make sure that all used lyxal_revisions are less or equal to the current lyxal_revision.
	ValidateRevision(lyxal_revision).visit_item(&ast)?;

	// Recreate the item.
	let mut reexport = TokenStream::new();
	Reexport {
		lyxal_revision,
		stream: &mut reexport,
	}
	.visit_item(&ast)
	.unwrap();

	// serialize implementation
	let mut serialize = TokenStream::new();
	SerializeVisitor::new(lyxal_revision, &mut serialize).visit_item(&ast).unwrap();

	let mut deserialize_structs = TokenStream::new();
	EnumStructsVisitor::new(lyxal_revision, &mut deserialize_structs).visit_item(&ast).unwrap();

	// deserialize implementation
	let deserialize = (1..=lyxal_revision)
		.map(|x| {
			// one for every lyxal_revision
			let mut deserialize = TokenStream::new();
			DeserializeVisitor {
				target: lyxal_revision,
				current: x,
				stream: &mut deserialize,
			}
			.visit_item(&ast)
			.unwrap();

			let lyxal_revision = x as u16;

			quote! {
				#lyxal_revision => {
					#deserialize
				}
			}
		})
		.collect::<Vec<_>>();

	let name = match ast.kind {
		ast::ItemKind::Enum(x) => x.name,
		ast::ItemKind::Struct(x) => x.name,
	};
	let lyxal_revision = lyxal_revision as u16;
	let lyxal_revision_error = format!("Invalid lyxal_revision `{{}}` for type `{}`", name);

	let serialize_impl = if attrs.0.serialize {
		quote! {
			impl ::revision::SerializeRevisioned for #name {
				fn serialize_lyxal_revisioned<W: ::std::io::Write>(&self, writer: &mut W) -> ::std::result::Result<(), ::revision::Error> {
					::revision::SerializeRevisioned::serialize_lyxal_revisioned(&<Self as ::revision::Revisioned>::lyxal_revision(),writer)?;
					#serialize
				}
			}
		}
	} else {
		quote! {}
	};

	let deserialize_impl = if attrs.0.deserialize {
		quote! {
			impl ::revision::DeserializeRevisioned for #name {
				fn deserialize_lyxal_revisioned<R: ::std::io::Read>(reader: &mut R) -> ::std::result::Result<Self, ::revision::Error> {
					let __lyxal_revision = <u16 as ::revision::DeserializeRevisioned>::deserialize_lyxal_revisioned(reader)?;
					match __lyxal_revision {
						#(#deserialize)*
						x => {
							return Err(::revision::Error::Deserialize(
								format!(#lyxal_revision_error,x)
							))
						}
					}
				}
			}
		}
	} else {
		quote! {}
	};

	Ok(quote! {
		#reexport
		#deserialize_structs

		#serialize_impl
		#deserialize_impl

		impl ::revision::Revisioned for #name {
			#[inline]
			fn lyxal_revision() -> u16{
				#lyxal_revision
			}
		}
	})
}
