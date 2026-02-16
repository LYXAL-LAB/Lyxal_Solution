use std::collections::HashMap;

use quote::{format_ident, quote};
use syn::{
    parse::Parse, parse_macro_input, punctuated::Punctuated, Attribute, Block, FnArg, Generics,
    Ident, ItemFn, LitStr, PatType, ReturnType, Signature, Token, Type, Visibility,
};

pub fn route_impl(
    args: proc_macro::TokenStream,
    tokens: proc_macro::TokenStream,
) -> proc_macro::TokenStream {
    let parsed_args = parse_macro_input!(args as ParsedRoutePath);
    let parsed_input = parse_macro_input!(tokens as ParsedInput);
    route_inner(parsed_input, parsed_args).into()
}

fn route_inner(
    parsed_input: ParsedInput,
    parsed_args: ParsedRoutePath,
) -> proc_macro2::TokenStream {
    let ParsedInput {
        attrs,
        vis,
        ident,
        block,
        generics,
        inputs,
        output,
        args,
        parent_route,
    } = parsed_input;

    let input_args = args.iter().map(|arg| &arg.ident);

    let param_segments = parsed_args
        .segments
        .iter()
        .enumerate()
        .filter_map(|(i, seg)| match seg {
            PathSegment::Param(name) | PathSegment::Stub(name) => Some((i, name)),
            PathSegment::Static(_) => None,
        });

    let param_queries =
        parsed_args
            .queries
            .iter()
            .enumerate()
            .filter_map(|(i, query)| match query {
                Query::Param(name) => Some((i, name)),
                Query::Static(_) => None,
            });

    let mut segment_to_arg = HashMap::new();

    for (seg_i, segment) in param_segments {
        let Some(arg_i) = args.iter().position(|arg| arg.ident == segment) else {
            let message = format!("param segment {:?} has no value to bind with.", segment);
            let err = syn::Error::new_spanned(&parsed_args.token, message);
            return err.to_compile_error();
        };
        segment_to_arg.insert(seg_i, arg_i);
    }

    let mut query_to_arg = HashMap::new();

    for (seg_i, segment) in param_queries {
        let Some(arg_i) = args.iter().position(|arg| arg.ident == segment) else {
            let message = format!("param query {:?} has no value to bind with.", segment);
            let err = syn::Error::new_spanned(&parsed_args.token, message);
            return err.to_compile_error();
        };
        query_to_arg.insert(seg_i, arg_i);
    }

    for arg in &args {
        if arg.ident == "children" {
            continue;
        }
        let do_match_arg = parsed_args.segments.iter().any(|seg| match seg {
            PathSegment::Static(_) => false,
            PathSegment::Param(name) | PathSegment::Stub(name) => arg.ident == name,
        });

        let do_match_query = parsed_args.queries.iter().any(|query| match query {
            Query::Static(_) => false,
            Query::Param(name) => arg.ident == name,
        });

        if !(do_match_arg || do_match_query) {
            let message = format!(
                "arg \"{}\" is neither a param segment nor a param query.",
                arg.ident
            );
            let err = syn::Error::new_spanned(&arg.ident, message);
            return err.to_compile_error();
        }
    }

    let segments = parsed_args
        .segments
        .iter()
        .enumerate()
        .map(|(i, arg)| match arg {
            PathSegment::Static(_) => {
                let string_holder = format_ident!("SegmentStringHolder{}__", i);
                quote!(leptos_typed_router::__private::StaticSegment<#string_holder>)
            }
            PathSegment::Param(_) => {
                let arg_i = segment_to_arg
                    .get(&i)
                    .copied()
                    .expect("param segment arg not found");
                let arg = &args[arg_i];
                let ty = &arg.ty;
                quote!(leptos_typed_router::__private::ParamSegment<#ty>)
            }
            PathSegment::Stub(_) => {
                let arg_i = segment_to_arg
                    .get(&i)
                    .copied()
                    .expect("stub segment arg not found");
                let arg = &args[arg_i];
                let ty = &arg.ty;
                quote!(leptos_typed_router::__private::StubSegment<#ty>)
            }
        });

    let queries = parsed_args.queries.iter().enumerate().map(|(i, query)| {
        let string_holder = format_ident!("QueryStringHolder{}__", i);
        match query {
            Query::Static(_) => {
                quote!(leptos_typed_router::__private::StaticQuery<#string_holder>)
            }
            Query::Param(_) => {
                let arg_i = query_to_arg
                    .get(&i)
                    .copied()
                    .expect("param query arg not found");
                let arg = &args[arg_i];
                let ty = &arg.ty;
                quote!(leptos_typed_router::__private::ParamQuery<#string_holder, #ty>)
            }
        }
    });

    let segments_string_holders =
        parsed_args
            .segments
            .iter()
            .enumerate()
            .map(|(i, arg)| match arg {
                PathSegment::Static(s) => {
                    let string_holder = format_ident!("SegmentStringHolder{}__", i);

                    quote! {
                        #[doc(hidden)]
                        pub struct #string_holder;

                        impl leptos_typed_router::__private::StaticStr for #string_holder {
                            const STRING: &'static str = #s;
                        }
                    }
                }
                _ => quote! {},
            });

    let queries_string_holders =
        parsed_args
            .queries
            .iter()
            .enumerate()
            .map(|(i, query)| match query {
                Query::Static(s) | Query::Param(s) => {
                    let string_holder = format_ident!("QueryStringHolder{}__", i);

                    quote! {
                        #[doc(hidden)]
                        pub struct #string_holder;

                        impl leptos_typed_router::__private::StaticStr for #string_holder {
                            const STRING: &'static str = #s;
                        }
                    }
                }
            });

    let args_destructure =
        parsed_args
            .segments
            .iter()
            .enumerate()
            .filter_map(|(i, arg)| match arg {
                PathSegment::Static(_) => None,
                PathSegment::Param(_) | PathSegment::Stub(_) => {
                    let arg_i = segment_to_arg
                        .get(&i)
                        .copied()
                        .expect("param or stub segment arg not found");
                    let arg = &args[arg_i];
                    Some(&arg.ident)
                }
            });

    let queries_destructure = parsed_args
        .queries
        .iter()
        .enumerate()
        .filter_map(|(i, query)| match query {
            Query::Static(_) => None,
            Query::Param(_) => {
                let arg_i = query_to_arg
                    .get(&i)
                    .copied()
                    .expect("param query arg not found.");
                let arg = &args[arg_i];
                Some(&arg.ident)
            }
        });

    let mut args_destru_ts = quote!(_);

    for arg in args_destructure.rev() {
        args_destru_ts = quote! {(#arg, #args_destru_ts)};
    }

    let mut recur_segments = quote!(());

    for seg in segments.rev() {
        recur_segments = quote! {(#seg, #recur_segments)}
    }

    let mut queries_destru_ts = quote!(_);

    for query in queries_destructure.rev() {
        queries_destru_ts = quote! {(#query, #queries_destru_ts)};
    }

    let mut recur_query = quote!(());

    for query in queries.rev() {
        recur_query = quote! {(#query, #recur_query)}
    }

    quote! {
        #[allow(non_camel_case_types)]
        #vis struct #ident;

        const _: () = {
            #(
                #segments_string_holders
            )*

            #(
                #queries_string_holders
            )*

            impl leptos_typed_router::__private::LeafRoute for #ident {
                type Args = leptos_typed_router::__private::RouteArgsDescriptor<#recur_segments, #recur_query>;

                fn into_view(args: Self::Args) -> impl leptos::IntoView + 'static {
                    fn __inner__(#inputs) #output #block

                    #[allow(unused)]
                    let leptos_typed_router::__private::RouteArgsDescriptor {
                        args,
                        query,
                    } = args;

                    let (#args_destru_ts, #queries_destru_ts) = (args, query);

                    __inner__(#(#input_args,)*)
                }
            }
        };

    }
}
enum PathSegment {
    Static(String),
    Param(String),
    Stub(String),
}

enum Query {
    Static(String),
    Param(String),
}

struct ParsedRoutePath {
    segments: Vec<PathSegment>,
    queries: Vec<Query>,
    token: LitStr,
}

impl Parse for ParsedRoutePath {
    fn parse(input: syn::parse::ParseStream) -> syn::Result<Self> {
        let token = input.parse::<LitStr>()?;
        let path = token.value();
        let (path, queries) = match path.split_once('?') {
            Some(v) => v,
            None => (path.as_str(), ""),
        };
        let segments = path
            .split('/')
            .filter(|seg| !seg.is_empty())
            .map(
                |seg| match seg.strip_prefix('<').and_then(|seg| seg.strip_suffix('>')) {
                    Some(param) => match param.strip_suffix("..") {
                        None => PathSegment::Param(param.to_string()),
                        Some(stub) => PathSegment::Stub(stub.to_string()),
                    },
                    None => PathSegment::Static(seg.to_string()),
                },
            )
            .collect();

        let queries = queries
            .split('&')
            .filter(|query| !query.is_empty())
            .map(|query| {
                match query
                    .strip_prefix('<')
                    .and_then(|query| query.strip_suffix('>'))
                {
                    Some(param) => Query::Param(param.to_string()),
                    None => Query::Static(query.to_string()),
                }
            })
            .collect();

        Ok(ParsedRoutePath {
            segments,
            token,
            queries,
        })
    }
}

#[derive(Debug)]
struct Arg {
    ident: Ident,
    ty: Type,
}

#[derive(Debug)]
struct ParsedInput {
    attrs: Vec<Attribute>,
    vis: Visibility,
    ident: Ident,
    block: Box<Block>,
    generics: Generics,
    inputs: Punctuated<FnArg, Token![,]>,
    output: ReturnType,
    args: Vec<Arg>,
    parent_route: Option<usize>,
}

impl Parse for ParsedInput {
    fn parse(input: syn::parse::ParseStream) -> syn::Result<Self> {
        let ItemFn {
            attrs,
            vis,
            sig,
            block,
        } = input.parse::<syn::ItemFn>()?;
        let Signature {
            ident,
            generics,
            inputs,
            output,
            ..
        } = sig;
        let args = inputs
            .iter()
            .filter_map(|arg| match arg {
                syn::FnArg::Receiver(_) => None,
                syn::FnArg::Typed(arg) => Some(arg),
            })
            .map(parse_args)
            .collect::<syn::Result<Vec<_>>>()?;

        let parent_route = args.iter().position(|arg| arg.ident == "children");

        Ok(ParsedInput {
            attrs,
            vis,
            ident,
            block,
            generics,
            inputs,
            output,
            args,
            parent_route,
        })
    }
}

fn parse_args(arg: &PatType) -> syn::Result<Arg> {
    let syn::Pat::Ident(ident) = &*arg.pat else {
        todo!()
    };

    Ok(Arg {
        ident: ident.ident.clone(),
        ty: (*arg.ty).clone(),
    })
}
