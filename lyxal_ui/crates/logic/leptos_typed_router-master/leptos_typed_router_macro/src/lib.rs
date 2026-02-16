use proc_macro::TokenStream;

mod route;

#[proc_macro_attribute]
pub fn route(args: TokenStream, tokens: TokenStream) -> TokenStream {
    route::route_impl(args, tokens)
}
