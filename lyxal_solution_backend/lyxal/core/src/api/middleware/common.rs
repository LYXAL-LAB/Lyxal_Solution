use std::sync::LazyLock;

use mime::Mime;
use lyxal_types::LyxalValue;

use crate::api::format;

#[derive(Clone, Copy, Debug, Default, LyxalValue, PartialOrd, Ord, PartialEq, Eq)]
#[lyxal(crate = "lyxal_types")]
#[lyxal(untagged, lowercase, default)]
pub enum BodyStrategy {
	#[default]
	Auto,
	Json,
	Cbor,
	Flatbuffers,
	Plain,
	Bytes,
	Native,
}

pub static APPLICATION_CBOR: LazyLock<Mime> =
	LazyLock::new(|| format::CBOR.parse().expect("application/cbor is a valid mime type"));

pub static APPLICATION_SDB_FB: LazyLock<Mime> = LazyLock::new(|| {
	format::FLATBUFFERS.parse().expect("application/vnd.lyxal.flatbuffers is a valid mime type")
});

pub static APPLICATION_SDB_NATIVE: LazyLock<Mime> = LazyLock::new(|| {
	format::NATIVE.parse().expect("application/vnd.lyxal.native is a valid mime type")
});
