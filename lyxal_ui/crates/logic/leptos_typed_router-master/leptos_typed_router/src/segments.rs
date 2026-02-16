use std::marker::PhantomData;
use std::{
    net::{IpAddr, Ipv4Addr, Ipv6Addr, SocketAddr, SocketAddrV4, SocketAddrV6},
    num::NonZero,
    str::FromStr,
    sync::Arc,
};

pub trait StaticStr: 'static {
    const STRING: &'static str;
}

pub struct StaticSegment<T>(PhantomData<T>);

pub struct ParamSegment<T>(PhantomData<T>);

pub struct StubSegment<T>(PhantomData<T>);

pub trait Segments: 'static {
    type Args: Send + Sync;

    fn try_match(path: &str) -> Option<(Self::Args, &str)>;

    fn fmt(args: &Self::Args, f: &mut std::fmt::Formatter) -> std::fmt::Result;
}

impl<T: StaticStr> Segments for StaticSegment<T> {
    type Args = ();
    fn try_match(path: &str) -> Option<(Self::Args, &str)> {
        let path = path.strip_prefix(T::STRING)?;
        let path = path.trim_start_matches('/');
        Some(((), path))
    }

    fn fmt(_: &Self::Args, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        std::fmt::Display::fmt(T::STRING, f)
    }
}

impl<T: FromSegment> Segments for ParamSegment<T> {
    type Args = T;
    fn try_match(path: &str) -> Option<(Self::Args, &str)> {
        let (segment, rest) = match path.split_once('/') {
            Some((s, rest)) => (s, rest.trim_start_matches('/')),
            None => (path, ""),
        };
        let value = T::parse(segment)?;
        Some((value, rest))
    }

    fn fmt(args: &Self::Args, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        FromSegment::fmt(args, f)
    }
}

impl<T: FromSegment> Segments for ParamSegment<Option<T>> {
    type Args = Option<T>;
    fn try_match(path: &str) -> Option<(Self::Args, &str)> {
        // Return Some(None) only if end of path
        // if a segment is still present and fails to parse, still return None.
        // It is an optionnal segment, not an "is okay to fail" segment.
        if path.trim_start_matches('/').is_empty() {
            Some((None, ""))
        } else {
            let (value, path) = ParamSegment::<T>::try_match(path)?;
            Some((Some(value), path))
        }
    }

    fn fmt(args: &Self::Args, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        if let Some(value) = args {
            FromSegment::fmt(value, f)
        } else {
            Ok(())
        }
    }
}

impl<T: FromPath> Segments for StubSegment<T> {
    type Args = T;
    fn try_match(path: &str) -> Option<(Self::Args, &str)> {
        Some((T::from_path(path), ""))
    }
    fn fmt(args: &Self::Args, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        T::fmt(args, f)
    }
}

impl Segments for () {
    type Args = ();

    fn try_match(path: &str) -> Option<(Self::Args, &str)> {
        path.trim_matches('/').is_empty().then_some(((), ""))
    }

    fn fmt(_: &Self::Args, _: &mut std::fmt::Formatter) -> std::fmt::Result {
        Ok(())
    }
}

impl<S: Segments> Segments for (S,) {
    type Args = S::Args;
    fn try_match(path: &str) -> Option<(Self::Args, &str)> {
        S::try_match(path)
    }

    fn fmt(args: &Self::Args, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        S::fmt(args, f)
    }
}

impl<T, S: Segments> Segments for (StaticSegment<T>, S)
where
    StaticSegment<T>: Segments<Args = ()>,
{
    type Args = S::Args;
    fn try_match(path: &str) -> Option<(Self::Args, &str)> {
        let (_, path) = StaticSegment::<T>::try_match(path)?;
        S::try_match(path)
    }

    fn fmt(args: &Self::Args, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        StaticSegment::<T>::fmt(&(), f)?;
        write!(f, "/")?;
        S::fmt(args, f)
    }
}

impl<T, S: Segments> Segments for (ParamSegment<T>, S)
where
    ParamSegment<T>: Segments,
{
    type Args = (<ParamSegment<T> as Segments>::Args, S::Args);
    fn try_match(path: &str) -> Option<(Self::Args, &str)> {
        let (value, path) = ParamSegment::<T>::try_match(path)?;
        let (other_values, path) = S::try_match(path)?;
        Some(((value, other_values), path))
    }

    fn fmt(args: &Self::Args, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        let (args1, args2) = args;
        ParamSegment::<T>::fmt(args1, f)?;
        write!(f, "/")?;
        S::fmt(args2, f)
    }
}

// Stub segment should always be last
impl<T> Segments for (StubSegment<T>, ())
where
    StubSegment<T>: Segments,
{
    type Args = (<StubSegment<T> as Segments>::Args, ());
    fn try_match(path: &str) -> Option<(Self::Args, &str)> {
        let (value, _) = StubSegment::<T>::try_match(path)?;
        Some(((value, ()), ""))
    }

    fn fmt(args: &Self::Args, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        StubSegment::<T>::fmt(&args.0, f)
    }
}

pub trait FromSegment: Sized + Send + Sync + 'static {
    fn parse(segment: &str) -> Option<Self>;

    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result;
}

macro_rules! into {
    ($ty:ty) => {
        impl FromSegment for $ty {
            fn parse(segment: &str) -> Option<Self> {
                Some(<$ty>::from(segment))
            }

            fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
                std::fmt::Display::fmt(self, f)
            }
        }
    };
    ($($ty:ty),*) => {
        $(into!($ty);)*
    };
}

macro_rules! from_str {
    ($ty:ty) => {
        impl FromSegment for $ty {
            fn parse(segment: &str) -> Option<Self> {
                FromStr::from_str(segment).ok()
            }

            fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
                std::fmt::Display::fmt(self, f)
            }
        }
    };
    ($($ty:ty),*) => {
        $(from_str!($ty);)*
    };
    (@non_zero, $($ty:ty),*) => {
        $(from_str!(NonZero<$ty>);)*
    }
}

// owned str
into!(String, Arc<str>, Box<str>);
// nums
from_str!(u8, u16, u32, u64, usize, i8, i16, i32, i64, isize);
// non zero nums
from_str!(@non_zero, u8, u16, u32, u64, usize, i8, i16, i32, i64, isize);
// other types
from_str!(
    bool,
    char,
    IpAddr,
    Ipv4Addr,
    Ipv6Addr,
    SocketAddr,
    SocketAddrV4,
    SocketAddrV6
);

pub trait FromPath: Sized + Send + Sync + 'static {
    fn from_path(path: &str) -> Self;

    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result;
}

macro_rules! from_path {
    ($ty:ty) => {
        impl FromPath for $ty {
            fn from_path(path: &str) -> Self {
                Self::from(path)
            }

            fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
                std::fmt::Display::fmt(self, f)
            }
        }
    };
    ($($ty:ty),*) => {
        $(from_path!($ty);)*
    };
}

// owned str
from_path!(String, Arc<str>, Box<str>);
