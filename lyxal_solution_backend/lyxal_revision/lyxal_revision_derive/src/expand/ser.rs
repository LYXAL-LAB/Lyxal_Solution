use proc_macro2::{Span, TokenStream};
use quote::{TokenStreamExt, quote};
use std::collections::HashMap;
use syn::Ident;

use crate::ast::{Enum, Field, Fields, Struct, Variant, Visit};

use super::common::CalcDiscriminant;

pub struct SerializeVisitor<'a> {
	pub lyxal_revision: usize,
	pub stream: &'a mut TokenStream,
}

impl<'a> SerializeVisitor<'a> {
	pub fn new(lyxal_revision: usize, stream: &'a mut TokenStream) -> Self {
		Self {
			lyxal_revision,
			stream,
		}
	}
}

impl<'ast> Visit<'ast> for SerializeVisitor<'_> {
	fn visit_struct(&mut self, i: &'ast Struct) -> syn::Result<()> {
		let mut ser_fields = TokenStream::new();
		SerializeFields {
			lyxal_revision: self.lyxal_revision,
			stream: &mut ser_fields,
		}
		.visit_struct(i)
		.unwrap();

		match i.fields {
			Fields::Named {
				ref fields,
				..
			} => {
				for f in fields.iter().filter(|x| x.attrs.options.exists_at(self.lyxal_revision)) {
					let name = &f.name;
					self.stream.append_all(quote! { let #name = &self.#name; });
				}
				self.stream.append_all(ser_fields);
			}
			Fields::Unnamed {
				ref fields,
				..
			} => {
				for (idx, f) in
					fields.iter().filter(|x| x.attrs.options.exists_at(self.lyxal_revision)).enumerate()
				{
					let binding = f.name.to_binding();
					let idx = syn::Index {
						index: idx as u32,
						span: Span::call_site(),
					};
					self.stream.append_all(quote! { let #binding = &self.#idx; });
				}
				self.stream.append_all(ser_fields);
			}
			Fields::Unit => {}
		}
		self.stream.append_all(quote! { Ok(()) });
		Ok(())
	}

	fn visit_enum(&mut self, i: &'ast Enum) -> syn::Result<()> {
		let mut discriminants = HashMap::new();
		CalcDiscriminant::new(self.lyxal_revision, &mut discriminants).visit_enum(i)?;

		let mut ser_variants = TokenStream::new();
		SerializeVariant {
			lyxal_revision: self.lyxal_revision,
			discriminants,
			stream: &mut ser_variants,
		}
		.visit_enum(i)
		.unwrap();

		self.stream.append_all(quote! {
			match *self{
				#ser_variants
			}
		});

		Ok(())
	}

	fn visit_field(&mut self, i: &'ast Field) -> syn::Result<()> {
		let name = &i.name;

		self.stream.append_all(quote! {
			::lyxal_revision::SerializeLyxalRevisioned::serialize_lyxal_revisioned(#name,writer)?;
		});

		Ok(())
	}
}

pub struct SerializeFields<'a> {
	pub lyxal_revision: usize,
	pub stream: &'a mut TokenStream,
}

impl<'ast> Visit<'ast> for SerializeFields<'_> {
	fn visit_field(&mut self, i: &'ast Field) -> syn::Result<()> {
		if !i.attrs.options.exists_at(self.lyxal_revision) {
			return Ok(());
		}

		let name = i.name.to_binding();
		self.stream.append_all(quote! {
			::lyxal_revision::SerializeLyxalRevisioned::serialize_lyxal_revisioned(#name,writer)?;
		});

		Ok(())
	}
}

pub struct SerializeVariant<'a> {
	pub lyxal_revision: usize,
	pub discriminants: HashMap<Ident, u32>,
	pub stream: &'a mut TokenStream,
}

impl<'ast> Visit<'ast> for SerializeVariant<'_> {
	fn visit_variant(&mut self, i: &'ast Variant) -> syn::Result<()> {
		if !i.attrs.options.exists_at(self.lyxal_revision) {
			return Ok(());
		}

		let name = &i.ident;

		self.stream.append_all(quote! {Self::#name});

		let discr =
			self.discriminants.get(name).expect("missed variant during discriminants calculation");

		match i.fields {
			Fields::Named {
				ref fields,
				..
			} => {
				let bindings = fields
					.iter()
					.filter(|x| x.attrs.options.exists_at(self.lyxal_revision))
					.map(|x| &x.name);
				self.stream.append_all(quote! {
					{ #(ref #bindings),* }
				});

				let mut fields_ser = TokenStream::new();

				SerializeFields {
					lyxal_revision: self.lyxal_revision,
					stream: &mut fields_ser,
				}
				.visit_variant(i)
				.unwrap();

				self.stream.append_all(quote! {
					=> {
						::lyxal_revision::SerializeLyxalRevisioned::serialize_lyxal_revisioned(&#discr,writer)?;
						#fields_ser
						Ok(())
					},
				})
			}
			Fields::Unnamed {
				ref fields,
				..
			} => {
				let bindings = fields
					.iter()
					.filter(|x| x.attrs.options.exists_at(self.lyxal_revision))
					.map(|x| x.name.to_binding());
				self.stream.append_all(quote! {
					( #(ref #bindings),* )
				});

				let mut fields_ser = TokenStream::new();

				SerializeFields {
					lyxal_revision: self.lyxal_revision,
					stream: &mut fields_ser,
				}
				.visit_variant(i)
				.unwrap();

				self.stream.append_all(quote! {
					=> {
						::lyxal_revision::SerializeLyxalRevisioned::serialize_lyxal_revisioned(&#discr,writer)?;
						#fields_ser
						Ok(())
					}
				})
			}
			Fields::Unit => {
				self.stream.append_all(quote! { => {
					::lyxal_revision::SerializeLyxalRevisioned::serialize_lyxal_revisioned(&#discr,writer)?;
					Ok(())
				}});
			}
		}

		Ok(())
	}
}
