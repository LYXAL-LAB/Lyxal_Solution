use crate::query::ParsedQueries;
use crate::route_args::RouteArgs;
use leptos::children::ToChildren;
use leptos::{either::*, prelude::TypedChildren, IntoView};

pub trait LeafRoute {
    type Args: RouteArgs;

    fn try_match(path: &str, query: &ParsedQueries) -> Option<Self::Args> {
        let (args, path) = Self::Args::try_match(path, query)?;
        path.trim_matches('/').is_empty().then_some(args)
    }

    fn into_view(args: Self::Args) -> impl IntoView + 'static;
}

pub trait BranchRoute {
    type Args: RouteArgs;

    fn try_match<'a>(path: &'a str, query: &ParsedQueries) -> Option<(Self::Args, &'a str)> {
        Self::Args::try_match(path, query)
    }

    fn into_view<C>(args: Self::Args, children: TypedChildren<C>) -> impl IntoView + 'static
    where
        C: IntoView + 'static;
}

impl<R: LeafRoute> LeafRoute for (R,) {
    type Args = R::Args;

    fn try_match(path: &str, query: &ParsedQueries) -> Option<Self::Args> {
        R::try_match(path, query)
    }

    fn into_view(args: Self::Args) -> impl IntoView + 'static {
        R::into_view(args)
    }
}

impl<R1: LeafRoute, R2: LeafRoute> LeafRoute for Either<R1, R2> {
    type Args = Either<R1::Args, R2::Args>;

    fn into_view(args: Self::Args) -> impl IntoView + 'static {
        match args {
            Either::Left(args) => Either::Left(R1::into_view(args)),
            Either::Right(args) => Either::Right(R2::into_view(args)),
        }
    }
}

impl<R: BranchRoute> BranchRoute for (R,) {
    type Args = R::Args;

    fn try_match<'a>(path: &'a str, query: &ParsedQueries) -> Option<(Self::Args, &'a str)> {
        R::try_match(path, query)
    }

    fn into_view<C>(args: Self::Args, children: TypedChildren<C>) -> impl IntoView + 'static
    where
        C: IntoView + 'static,
    {
        R::into_view(args, children)
    }
}

macro_rules! impl_routes {
    ($first:ident, $second: ident) => {
        impl<$second: BranchRoute, $first: LeafRoute> LeafRoute for ($second, $first) {
            type Args = ($second::Args, $first::Args);

            fn into_view(args: Self::Args) -> impl IntoView + 'static {
                let (second, first) = args;
                let children = ToChildren::to_children(move || $first::into_view(first));
                $second::into_view(second, children)
            }
        }

        impl<$second: BranchRoute, $first: BranchRoute> BranchRoute for ($second, $first) {
            type Args = ($second::Args, $first::Args);

            fn into_view<Child>(args: Self::Args, children: TypedChildren<Child>) -> impl IntoView + 'static
            where
                Child: IntoView + 'static
            {
                let (second, first) = args;
                let children = ToChildren::to_children(move || $first::into_view(first, children));
                $second::into_view(second, children)
            }
        }
    };
    ($first:ident, $($ty:ident),*) => {
        impl<$($ty: BranchRoute,)* $first: LeafRoute> LeafRoute for ($($ty,)* $first) {
            type Args = ($($ty::Args,)* $first::Args);

            fn into_view(args: Self::Args) -> impl IntoView + 'static {
                #[allow(non_snake_case)]
                let ($($ty,)* first) = args;
                let children = ToChildren::to_children(move || $first::into_view(first));
                <($($ty,)*) as BranchRoute>::into_view(($($ty,)*), children)
            }
        }

        impl<$($ty: BranchRoute,)* $first: BranchRoute> BranchRoute for ($($ty,)* $first) {
            type Args = ($($ty::Args,)* $first::Args);

            fn into_view<Child>(args: Self::Args, children: TypedChildren<Child>) -> impl IntoView + 'static
            where
                Child: IntoView + 'static
            {
                #[allow(non_snake_case)]
                let ($($ty,)* first) = args;
                let children = ToChildren::to_children(move || $first::into_view(first, children));
                <($($ty,)*) as BranchRoute>::into_view(($($ty,)*), children)
            }
        }
    };
    ($either:ident => $($ty:ident),*) => {
        impl<$($ty: LeafRoute,)*> LeafRoute for $either<$($ty,)*> {
            type Args = $either<$($ty::Args,)*>;

            fn into_view(args: Self::Args) -> impl IntoView + 'static {
                match args {
                    $(
                        $either::$ty(args) => $either::$ty($ty::into_view(args)),
                    )*
                }
            }
        }

        impl<$($ty: BranchRoute,)*> BranchRoute for $either<$($ty,)*> {
            type Args = $either<$($ty::Args,)*>;

            fn into_view<Child>(args: Self::Args, children: TypedChildren<Child>) -> impl IntoView + 'static
            where
                Child: IntoView + 'static,
            {
                match args {
                    $(
                        $either::$ty(args) => $either::$ty($ty::into_view(args, children)),
                    )*
                }
            }
        }
    }
}

crate::tuples!(impl_routes);
crate::either_of!(impl_routes);
