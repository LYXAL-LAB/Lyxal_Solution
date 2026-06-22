//! Encoding functions

use crate::db::exec::function::FunctionRegistry;
use crate::{define_pure_function, register_functions};

// Base64 encoding
define_pure_function!(EncodingBase64Decode, "encoding::base64::decode", (value: String) -> Any, crate::function::encoding::base64::decode);
define_pure_function!(EncodingBase64Encode, "encoding::base64::encode", (value: Any) -> String, crate::function::encoding::base64::encode);

// CBOR encoding
define_pure_function!(EncodingCborDecode, "encoding::cbor::decode", (value: Any) -> Any, crate::function::encoding::cbor::decode);
define_pure_function!(EncodingCborEncode, "encoding::cbor::encode", (value: Any) -> Any, crate::function::encoding::cbor::encode);

pub fn register(registry: &mut FunctionRegistry) {
	register_functions!(
		registry,
		EncodingBase64Decode,
		EncodingBase64Encode,
		EncodingCborDecode,
		EncodingCborEncode,
	);
}
