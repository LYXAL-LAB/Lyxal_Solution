use crate::{
    query::{ParseQuery, ParsedQueries},
    segments::Segments,
};
use leptos::either::*;

pub struct RouteArgsDescriptor<S: Segments, Q: ParseQuery> {
    pub args: S::Args,
    pub query: Q::Args,
}

impl<S: Segments, Q: ParseQuery> Clone for RouteArgsDescriptor<S, Q>
where
    S::Args: Clone,
    Q::Args: Clone,
{
    fn clone(&self) -> Self {
        RouteArgsDescriptor {
            args: self.args.clone(),
            query: self.query.clone(),
        }
    }
}

pub trait RouteArgs: Sized + Send + Sync + 'static {
    fn try_match<'a>(path: &'a str, query: &ParsedQueries) -> Option<(Self, &'a str)>;
}

impl<S: Segments, Q: ParseQuery> RouteArgs for RouteArgsDescriptor<S, Q> {
    fn try_match<'a>(path: &'a str, query: &ParsedQueries) -> Option<(Self, &'a str)> {
        let (args, path) = S::try_match(path)?;
        let query = Q::try_parse(query)?;
        Some((RouteArgsDescriptor { args, query }, path))
    }
}

impl<A1: RouteArgs, A2: RouteArgs> RouteArgs for Either<A1, A2> {
    fn try_match<'a>(path: &'a str, query: &ParsedQueries) -> Option<(Self, &'a str)> {
        if let Some((value, path)) = A1::try_match(path, query) {
            Some((Either::Left(value), path))
        } else if let Some((value, path)) = A2::try_match(path, query) {
            Some((Either::Right(value), path))
        } else {
            None
        }
    }
}

macro_rules! impl_route_args {
    ($($ty:ident),*) => {
        impl<$($ty: RouteArgs,)*> RouteArgs for ($($ty,)*) {
            fn try_match<'a>(path: &'a str, query: &ParsedQueries) -> Option<(Self, &'a str)> {
                $(
                    #[allow(non_snake_case)]
                    let ($ty, path) = $ty::try_match(path, query)?;
                )*
                Some((($($ty,)*), path))
            }
        }
    };
    ($either:ident => $($ty:ident),*) => {
        impl<$($ty: RouteArgs,)*> RouteArgs for $either<$($ty,)*> {
            fn try_match<'a>(path: &'a str, query: &ParsedQueries) -> Option<(Self, &'a str)> {
                $(
                    if let Some((value, path)) = $ty::try_match(path, query) {
                        return Some(($either::$ty(value), path))
                    }
                )*
                None
            }
        }
    }
}

crate::tuples!(impl_route_args);
crate::either_of!(impl_route_args);
