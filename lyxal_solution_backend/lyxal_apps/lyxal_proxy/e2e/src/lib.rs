#![allow(dead_code)]

mod http_utils;
mod mock;
mod lyxal_proxy;
#[cfg(test)]
#[cfg(not(tarpaulin))]
mod tests;

const BUFFER_SIZE: usize = 4096;
