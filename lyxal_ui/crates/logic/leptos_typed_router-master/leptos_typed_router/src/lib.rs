mod query;
mod route_args;
mod routes;
mod segments;

macro_rules! tuples {
    ($cb: ident) => {
        $crate::tuples!(
            @inner
            $cb,
            A,
            B,
            C,
            D,
            E,
            F,
            G,
            H,
            I,
            J,
            K,
            L,
            M,
            N,
            O,
            P,
            Q,
            R,
            S,
            T,
            U,
            V,
            W,
            Y,
            Z
        );
    };
    (@inner $cb: ident, $first: ident, $second: ident) => {
        $cb!($first, $second);
    };
    (@inner $cb: ident, $first: ident, $second: ident, $($ty:ident),+) => {
        $cb!($first, $second, $($ty),*);
        $crate::tuples!(@inner $cb, $second, $($ty),*);
    };
}

macro_rules! either_of {
    ($cb: ident) => {
        $cb!(EitherOf3 => A, B, C);
        $cb!(EitherOf4 => A, B, C, D);
        $cb!(EitherOf5 => A, B, C, D, E);
        $cb!(EitherOf6 => A, B, C, D, E, F);
        $cb!(EitherOf7 => A, B, C, D, E, F, G);
        $cb!(EitherOf8 => A, B, C, D, E, F, G, H);
        $cb!(EitherOf9 => A, B, C, D, E, F, G, H, I);
        $cb!(EitherOf10 => A, B, C, D, E, F, G, H, I, J);
        $cb!(EitherOf11 => A, B, C, D, E, F, G, H, I, J, K);
        $cb!(EitherOf12 => A, B, C, D, E, F, G, H, I, J, K, L);
        $cb!(EitherOf13 => A, B, C, D, E, F, G, H, I, J, K, L, M);
        $cb!(EitherOf14 => A, B, C, D, E, F, G, H, I, J, K, L, M, N);
        $cb!(EitherOf15 => A, B, C, D, E, F, G, H, I, J, K, L, M, N, O);
        $cb!(EitherOf16 => A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P);
    };
}

pub(crate) use either_of;
pub(crate) use tuples;

#[doc(hidden)]
pub mod __private {
    pub use crate::query::{ParamQuery, StaticQuery};
    pub use crate::route_args::RouteArgsDescriptor;
    pub use crate::routes::LeafRoute;
    pub use crate::segments::{ParamSegment, StaticSegment, StaticStr, StubSegment};
}

#[cfg(test)]
mod test {
    use crate::routes::LeafRoute;
    use crate::{self as leptos_typed_router};
    use leptos::prelude::RenderHtml;
    use leptos::IntoView;
    use leptos_typed_router_macro::route;

    #[route("/hello/<name>/<age>?<id>")]
    pub fn test_route(name: String, age: u8, id: usize) -> impl IntoView {
        format!("{} {} {}", name, age, id)
    }

    #[route("/hello/<stub..>?<id>")]
    pub fn stub_route(stub: String, id: usize) -> impl IntoView {
        format!("{} {}", stub, id)
    }

    fn render<R: LeafRoute>(raw_path: &str) -> Option<String> {
        let (path, queries) = match raw_path.split_once('?') {
            Some(v) => v,
            None => (raw_path, ""),
        };
        let queries = crate::query::ParsedQueries::parse(queries);
        let args = R::try_match(path, &queries)?;
        let view = R::into_view(args).into_view().to_html();
        Some(view)
    }

    #[test]
    fn test1() {
        let rendered = render::<test_route>("hello/john/56?id=45").unwrap();
        assert_eq!(rendered, "john 56 45");
    }
}
