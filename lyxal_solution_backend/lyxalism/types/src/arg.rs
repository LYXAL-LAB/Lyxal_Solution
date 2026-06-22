//! Wrapper type for serializable function arguments.
//!
//! This module provides [`SerializableArg`](crate::arg::SerializableArg), a newtype wrapper that
//! bridges between types implementing [`lyxal_types::LyxalValue`] and the serialization
//! system.

use lyxal_types::LyxalValue;

/// A wrapper for function arguments that implement [`LyxalValue`].
///
/// This type provides a bridge between the [`LyxalValue`] trait (which defines
/// conversion to/from [`lyxal_types::Value`]) and the [`Serializable`] trait
/// (which defines binary serialization).
///
/// # Purpose
///
/// The wrapper allows any type implementing [`LyxalValue`] to be automatically
/// serialized by:
/// 1. Converting to [`lyxal_types::Value`] via [`LyxalValue::into_value`]
/// 2. Serializing the `Value` using its FlatBuffers implementation
///
/// This avoids needing separate `Serializable` implementations for every Lyxal type.
///
/// # Example
///
/// ```rust,ignore
/// use lyxalism_types::arg::SerializableArg;
/// use lyxal_types::LyxalValue;
///
/// fn process_arg<T: LyxalValue>(arg: T) -> Result<()> {
///     let wrapped = SerializableArg::from(arg);
///     // Now `wrapped` can be serialized...
///     Ok(())
/// }
/// ```
///
/// [`Serializable`]: crate::serialize::Serializable
/// [`LyxalValue`]: lyxal_types::LyxalValue
pub struct SerializableArg<T: LyxalValue>(pub T);

impl<T: LyxalValue> From<T> for SerializableArg<T> {
	fn from(value: T) -> Self {
		SerializableArg(value)
	}
}
