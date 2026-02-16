use std::{
    collections::{hash_map::Entry, HashMap, HashSet, VecDeque},
    hash::Hash,
    marker::PhantomData,
};
use std::{
    net::{IpAddr, Ipv4Addr, Ipv6Addr, SocketAddr, SocketAddrV4, SocketAddrV6},
    num::NonZero,
    str::FromStr,
    sync::Arc,
};

use crate::segments::StaticStr;

#[derive(Debug)]
pub enum QueryValue<'a> {
    NoValue,
    Single(&'a str),
    Multiple(Vec<Option<&'a str>>),
}

#[derive(Default, Debug)]
pub struct ParsedQueries<'a> {
    queries: HashMap<&'a str, QueryValue<'a>>,
    raw: &'a str,
}

impl<'a> ParsedQueries<'a> {
    pub fn parse(query: &'a str) -> Self {
        let mut queries = HashMap::new();
        for q in query.split('&').filter(|q| !q.is_empty()) {
            if let Some((name, value)) = q.split_once('=') {
                Self::push(&mut queries, name, Some(value));
            } else {
                Self::push(&mut queries, q, None);
            }
        }
        ParsedQueries {
            queries,
            raw: query,
        }
    }

    pub fn get_raw(&self) -> &'a str {
        self.raw
    }

    pub fn get<'b>(&'b self, name: &str) -> Option<&'b QueryValue<'a>> {
        self.queries.get(name)
    }

    fn push(queries: &mut HashMap<&'a str, QueryValue<'a>>, name: &'a str, value: Option<&'a str>) {
        match queries.entry(name) {
            Entry::Occupied(mut occupied_entry) => {
                let old_value = occupied_entry.get_mut();
                let new_value = match old_value {
                    QueryValue::NoValue => QueryValue::Multiple(vec![None, value]),
                    QueryValue::Single(single) => QueryValue::Multiple(vec![Some(single), value]),
                    QueryValue::Multiple(multi) => {
                        let mut multi = std::mem::take(multi);
                        multi.push(value);
                        QueryValue::Multiple(multi)
                    }
                };
                *old_value = new_value;
            }
            Entry::Vacant(vacant_entry) => {
                let value = match value {
                    Some(value) => QueryValue::Single(value),
                    None => QueryValue::NoValue,
                };
                vacant_entry.insert(value);
            }
        }
    }
}

pub trait ParseQuery: 'static {
    type Args: Send + Sync;

    fn try_parse(query: &ParsedQueries) -> Option<Self::Args>;
}

impl ParseQuery for () {
    type Args = ();

    fn try_parse(_: &ParsedQueries) -> Option<Self::Args> {
        Some(())
    }
}

pub struct StaticQuery<T>(PhantomData<T>);

impl<T: StaticStr> ParseQuery for StaticQuery<T> {
    type Args = ();

    fn try_parse(query: &ParsedQueries) -> Option<Self::Args> {
        query.get_raw().contains(T::STRING).then_some(())
    }
}

impl<T: StaticStr, Q: ParseQuery> ParseQuery for (StaticQuery<T>, Q) {
    type Args = Q::Args;

    fn try_parse(query: &ParsedQueries) -> Option<Self::Args> {
        StaticQuery::<T>::try_parse(query)?;
        Q::try_parse(query)
    }
}

pub struct ParamQuery<S, T>(PhantomData<(S, T)>);

impl<S: StaticStr, T: FromQuery, Q: ParseQuery> ParseQuery for (ParamQuery<S, T>, Q) {
    type Args = (T, Q::Args);

    fn try_parse(query: &ParsedQueries) -> Option<Self::Args> {
        let a = ParamQuery::<S, T>::try_parse(query)?;
        let b = Q::try_parse(query)?;
        Some((a, b))
    }
}

impl<S: StaticStr, T: FromQuery> ParseQuery for ParamQuery<S, T> {
    type Args = T;

    fn try_parse(query: &ParsedQueries) -> Option<Self::Args> {
        query.get(S::STRING).and_then(T::from_query)
    }
}

impl<S: StaticStr, T: FromQuery> ParseQuery for ParamQuery<S, Option<T>> {
    type Args = Option<T>;

    fn try_parse(query: &ParsedQueries) -> Option<Self::Args> {
        match query.get(S::STRING).map(T::from_query) {
            None => Some(None),                     // not present
            Some(None) => None,                     // fails to parse
            Some(Some(value)) => Some(Some(value)), // parse succeeded
        }
    }
}

pub trait FromQuery: Sized + Send + Sync + 'static {
    fn from_query(value: &QueryValue) -> Option<Self>;
}

impl FromQuery for bool {
    fn from_query(value: &QueryValue) -> Option<Self> {
        match value {
            QueryValue::Single(val) if *val == "true" => Some(true),
            QueryValue::Single(val) if *val == "false" => Some(false),
            _ => None,
        }
    }
}

impl<T: FromQuery> FromQuery for Vec<T> {
    fn from_query(value: &QueryValue) -> Option<Self> {
        match value {
            QueryValue::NoValue => {
                let value = T::from_query(&QueryValue::NoValue)?;
                Some(vec![value])
            }
            QueryValue::Single(val) => {
                let value = T::from_query(&QueryValue::Single(val))?;
                Some(vec![value])
            }
            QueryValue::Multiple(vec) => vec
                .iter()
                .map(|query| match query {
                    Some(v) => QueryValue::Single(v),
                    None => QueryValue::NoValue,
                })
                .map(|query| T::from_query(&query))
                .collect::<Option<Vec<_>>>(),
        }
    }
}

impl<T: FromQuery> FromQuery for VecDeque<T> {
    fn from_query(value: &QueryValue) -> Option<Self> {
        match value {
            QueryValue::NoValue => {
                let value = T::from_query(&QueryValue::NoValue)?;
                let mut v = VecDeque::new();
                v.push_front(value);
                Some(v)
            }
            QueryValue::Single(val) => {
                let value = T::from_query(&QueryValue::Single(val))?;
                let mut v = VecDeque::new();
                v.push_front(value);
                Some(v)
            }
            QueryValue::Multiple(vec) => vec
                .iter()
                .map(|query| match query {
                    Some(v) => QueryValue::Single(v),
                    None => QueryValue::NoValue,
                })
                .map(|query| T::from_query(&query))
                .collect::<Option<VecDeque<_>>>(),
        }
    }
}

impl<T: FromQuery + Hash + Eq> FromQuery for HashSet<T> {
    fn from_query(value: &QueryValue) -> Option<Self> {
        match value {
            QueryValue::NoValue => {
                let value = T::from_query(&QueryValue::NoValue)?;
                let mut set = HashSet::new();
                set.insert(value);
                Some(set)
            }
            QueryValue::Single(val) => {
                let value = T::from_query(&QueryValue::Single(val))?;
                let mut set = HashSet::new();
                set.insert(value);
                Some(set)
            }
            QueryValue::Multiple(vec) => vec
                .iter()
                .map(|query| match query {
                    Some(v) => QueryValue::Single(v),
                    None => QueryValue::NoValue,
                })
                .map(|query| T::from_query(&query))
                .collect::<Option<HashSet<_>>>(),
        }
    }
}

macro_rules! into {
    ($ty:ty) => {
        impl FromQuery for $ty {
            fn from_query(value: &QueryValue) -> Option<Self> {
                match value {
                    QueryValue::Single(val) => Some(<$ty>::from(*val)),
                    _ => None
                }
            }
        }
    };
    ($($ty:ty),*) => {
        $(into!($ty);)*
    };
}

macro_rules! from_str {
    ($ty:ty) => {
        impl FromQuery for $ty {
            fn from_query(value: &QueryValue) -> Option<Self> {
                match value {
                    QueryValue::Single(val) => FromStr::from_str(val).ok(),
                    _ => None
                }
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
    char,
    IpAddr,
    Ipv4Addr,
    Ipv6Addr,
    SocketAddr,
    SocketAddrV4,
    SocketAddrV6
);
