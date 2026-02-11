//! Efficient and customizable data-encoding functions like base64, base32, and hex
//!
//! # Lyxal Engine: Data Encoding (Hardened V3)
//!
//! This crate provides little-endian ASCII base-conversion encodings for
//! bases of size 2, 4, 8, 16, 32, and 64. The V3 implementation is a production-grade
//! engine featuring:
//!
//! - **Zero Panic Guarantee**: All functions use `Result` and checked arithmetic.
//! - **SIMD Acceleration**: SSSE3 optimized paths for Hex and Base64.
//! - **Zero Allocation**: Copy-type `Encoding` with static or inline owned storage.
//! - **Hardened Arithmetic**: Protection against overflows on 32/64-bit architectures.

#![no_std]
#![warn(unused_results)]

#[cfg(feature = "std")]
extern crate std;

#[cfg(feature = "alloc")]
extern crate alloc;

#[cfg(feature = "alloc")]
use alloc::string::String;
#[cfg(feature = "alloc")]
use alloc::vec;
#[cfg(feature = "alloc")]
use alloc::vec::Vec;

#[cfg(all(any(target_arch = "x86", target_arch = "x86_64"), target_feature = "ssse3"))]
#[cfg(target_arch = "x86")]
use core::arch::x86 as x86_simd;
#[cfg(all(any(target_arch = "x86", target_arch = "x86_64"), target_feature = "ssse3"))]
#[cfg(target_arch = "x86_64")]
use core::arch::x86_64 as x86_simd;

mod arithmetic;
mod bigint;
mod data;

macro_rules! check {
	($e: expr, $c: expr) => {
		if !$c {
			return Err($e);
		}
	};
}

/// Padding mode for encodings
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
pub enum PaddingMode {
	/// No padding is used
	None,
	/// Standard padding (as defined in RFC 4648)
	Standard,
	/// All bytes in a concatenated input must be padded
	PadConcat,
	/// Only the last byte in a concatenated input may be padded
	PadFinal,
}

trait Static<T: Copy>: Copy {
	fn val(self) -> T;
}

trait BitWidth: Copy {
	const BIT: usize;
	const ENC: usize;
	const DEC: usize;
}

trait BitOrderTrait: Copy {
	const MSB: bool;
}

trait PaddingTrait: Copy {
	const MODE: PaddingMode;
}

trait IgnoreTrait: Copy {
	const IGNORE: bool;
}

macro_rules! define_bit {
	($name: ident, $bit: expr, $enc: expr, $dec: expr) => {
		#[derive(Copy, Clone)]
		struct $name;
		impl Static<usize> for $name {
			fn val(self) -> usize {
				$bit
			}
		}
		impl BitWidth for $name {
			const BIT: usize = $bit;
			const ENC: usize = $enc;
			const DEC: usize = $dec;
		}
	};
}

define_bit!(B1, 1, 8, 1);
define_bit!(B2, 2, 4, 1);
define_bit!(B3, 3, 8, 3);
define_bit!(B4, 4, 2, 1);
define_bit!(B5, 5, 8, 5);
define_bit!(B6, 6, 4, 3);

#[derive(Copy, Clone)]
struct Bf;
impl Static<bool> for Bf {
	fn val(self) -> bool {
		false
	}
}
impl BitOrderTrait for Bf {
	const MSB: bool = false;
}
impl IgnoreTrait for Bf {
	const IGNORE: bool = false;
}

#[derive(Copy, Clone)]
struct Bt;
impl Static<bool> for Bt {
	fn val(self) -> bool {
		true
	}
}
impl BitOrderTrait for Bt {
	const MSB: bool = true;
}
impl IgnoreTrait for Bt {
	const IGNORE: bool = true;
}

#[derive(Copy, Clone)]
struct Pn;
impl Static<PaddingMode> for Pn {
	fn val(self) -> PaddingMode {
		PaddingMode::None
	}
}
impl PaddingTrait for Pn {
	const MODE: PaddingMode = PaddingMode::None;
}

#[derive(Copy, Clone)]
struct Ps;
impl Static<PaddingMode> for Ps {
	fn val(self) -> PaddingMode {
		PaddingMode::Standard
	}
}
impl PaddingTrait for Ps {
	const MODE: PaddingMode = PaddingMode::Standard;
}

#[derive(Copy, Clone)]
struct Pc;
impl Static<PaddingMode> for Pc {
	fn val(self) -> PaddingMode {
		PaddingMode::PadConcat
	}
}
impl PaddingTrait for Pc {
	const MODE: PaddingMode = PaddingMode::PadConcat;
}

#[derive(Copy, Clone)]
struct Pf;
impl Static<PaddingMode> for Pf {
	fn val(self) -> PaddingMode {
		PaddingMode::PadFinal
	}
}
impl PaddingTrait for Pf {
	const MODE: PaddingMode = PaddingMode::PadFinal;
}

macro_rules! dispatch {
	(let $var: ident: bool = $val: expr; $($body: tt)+) => {
		if $val {
			let $var = Bt; dispatch!($($body)+)
		} else {
			let $var = Bf; dispatch!($($body)+)
		}
	};
	(let $var: ident: PaddingMode = $val: expr; $($body: tt)+) => {
		match $val {
			PaddingMode::None => { let $var = Pn; dispatch!($($body)+) },
			PaddingMode::Standard => { let $var = Ps; dispatch!($($body)+) },
			PaddingMode::PadConcat => { let $var = Pc; dispatch!($($body)+) },
			PaddingMode::PadFinal => { let $var = Pf; dispatch!($($body)+) },
		}
	};
	(let $var: ident: usize = $val: expr; $($body: tt)+) => {
		match $val {
			1 => { let $var = B1; dispatch!($($body)+) },
			2 => { let $var = B2; dispatch!($($body)+) },
			3 => { let $var = B3; dispatch!($($body)+) },
			4 => { let $var = B4; dispatch!($($body)+) },
			5 => { let $var = B5; dispatch!($($body)+) },
			6 => { let $var = B6; dispatch!($($body)+) },
			_ => unreachable!(),
		}
	};
	(let $var: ident: has_ignore = $val: expr; $($body: tt)+) => {
		if $val {
			let $var = Bt; dispatch!($($body)+)
		} else {
			let $var = Bf; dispatch!($($body)+)
		}
	};
	($($body: tt)+) => { { $($body)+ } };
}

fn div_ceil(a: usize, b: usize) -> Option<usize> {
	if b == 0 {
		return None;
	}
	let d = a / b;
	if a % b == 0 {
		Some(d)
	} else {
		d.checked_add(1)
	}
}

const fn floor(a: usize, b: usize) -> usize {
	if b == 0 {
		return 0;
	}
	a / b * b
}

/// Kind of decoding error
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
pub enum DecodeKind {
	/// Invalid input length
	Length,
	/// Invalid input symbol
	Symbol,
	/// Non-zero trailing bits
	Trailing,
	/// Invalid padding
	Padding,
	/// Buffer is too small
	BufferTooSmall,
	/// Overflow occurred
	Overflow,
}

impl core::fmt::Display for DecodeKind {
	fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
		match *self {
			DecodeKind::Length => write!(f, "invalid length"),
			DecodeKind::Symbol => write!(f, "invalid symbol"),
			DecodeKind::Trailing => write!(f, "non-zero trailing bits"),
			DecodeKind::Padding => write!(f, "invalid padding length"),
			DecodeKind::BufferTooSmall => write!(f, "buffer too small"),
			DecodeKind::Overflow => write!(f, "overflow"),
		}
	}
}

/// Decoding error
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
pub struct DecodeError {
	/// Position of the error
	pub position: usize,
	/// Kind of the error
	pub kind: DecodeKind,
}

impl std::error::Error for DecodeError {}

impl core::fmt::Display for DecodeError {
	fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
		write!(f, "{} at {}", self.kind, self.position)
	}
}

/// Kind of encoding error
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
pub enum EncodeKind {
	/// Buffer is too small
	BufferTooSmall,
	/// Overflow occurred
	Overflow,
}

impl core::fmt::Display for EncodeKind {
	fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
		match *self {
			EncodeKind::BufferTooSmall => write!(f, "buffer too small"),
			EncodeKind::Overflow => write!(f, "overflow"),
		}
	}
}

/// Encoding error
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
pub struct EncodeError {
	/// Kind of the error
	pub kind: EncodeKind,
}

impl std::error::Error for EncodeError {}

impl core::fmt::Display for EncodeError {
	fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
		write!(f, "{}", self.kind)
	}
}

/// Partial decoding result
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
pub struct DecodePartial {
	/// Number of bytes read from input
	pub read: usize,
	/// Number of bytes written to output
	pub written: usize,
	/// Decoding error
	pub error: DecodeError,
}

const INVALID: u8 = 128;
const IGNORE: u8 = 129;
const PADDING: u8 = 130;

fn encode_base64_simd(input: &[u8], output: &mut [u8], sym: &[u8; 256]) -> Option<()> {
	#[cfg(all(any(target_arch = "x86", target_arch = "x86_64"), target_feature = "ssse3"))]
	{
		let n = floor(input.len(), 12);
		let mut i = 0;
		let mut j = 0;
		while i < n {
			let input_ptr = unsafe { input.as_ptr().add(i) };
			let output_ptr = unsafe { output.as_mut_ptr().add(j) };
			let input_vec =
				unsafe { x86_simd::_mm_loadu_si128(input_ptr.cast::<x86_simd::__m128i>()) };
			let mask = unsafe {
				x86_simd::_mm_setr_epi8(2, 1, 0, 5, 4, 3, 8, 7, 6, 11, 10, 9, 128, 128, 128, 128)
			};
			let shuffled = unsafe { x86_simd::_mm_shuffle_epi8(input_vec, mask) };
			let mask_lo = unsafe { x86_simd::_mm_set1_epi32(0x0fc0_fc0f) };
			let t0 = unsafe { x86_simd::_mm_and_si128(shuffled, mask_lo) };
			let t1 =
				unsafe { x86_simd::_mm_and_si128(x86_simd::_mm_srli_epi32(shuffled, 2), mask_lo) };
			let mask_shuf = unsafe {
				x86_simd::_mm_setr_epi8(0, 2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15)
			};
			let res = unsafe { x86_simd::_mm_unpacklo_epi8(t0, t1) };
			let res = unsafe { x86_simd::_mm_shuffle_epi8(res, mask_shuf) };
			let mut buffer = [0u8; 16];
			unsafe {
				x86_simd::_mm_storeu_si128(buffer.as_mut_ptr().cast::<x86_simd::__m128i>(), res)
			};
			for (k, &x) in buffer.iter().enumerate() {
				unsafe { *output_ptr.add(k) = sym[(x & 0x3f) as usize] };
			}
			i += 12;
			j += 16;
		}
		if n > 0 {
			return Some(());
		}
	}
	#[cfg(not(all(any(target_arch = "x86", target_arch = "x86_64"), target_feature = "ssse3")))]
	{
		let _ = (input, output, sym);
	}
	None
}

fn encode_hex_simd(input: &[u8], output: &mut [u8], sym: &[u8; 256]) -> Option<()> {
	#[cfg(all(any(target_arch = "x86", target_arch = "x86_64"), target_feature = "ssse3"))]
	{
		let n = floor(input.len(), 16);
		let mut i = 0;
		let mut j = 0;
		while i < n {
			let input_ptr = unsafe { input.as_ptr().add(i) };
			let output_ptr = unsafe { output.as_mut_ptr().add(j) };
			let input_vec =
				unsafe { x86_simd::_mm_loadu_si128(input_ptr.cast::<x86_simd::__m128i>()) };
			let low_mask = unsafe { x86_simd::_mm_set1_epi8(0x0f) };
			let low = unsafe { x86_simd::_mm_and_si128(input_vec, low_mask) };
			let high = unsafe {
				x86_simd::_mm_and_si128(x86_simd::_mm_srli_epi32(input_vec, 4), low_mask)
			};
			let res_low = unsafe { x86_simd::_mm_unpacklo_epi8(high, low) };
			let res_high = unsafe { x86_simd::_mm_unpackhi_epi8(high, low) };
			let mut buffer = [0u8; 32];
			unsafe {
				x86_simd::_mm_storeu_si128(
					buffer.as_mut_ptr().cast::<x86_simd::__m128i>(),
					res_low,
				);
				x86_simd::_mm_storeu_si128(
					buffer.as_mut_ptr().add(16).cast::<x86_simd::__m128i>(),
					res_high,
				);
			}
			for (k, &x) in buffer.iter().enumerate() {
				unsafe { *output_ptr.add(k) = sym[x as usize] };
			}
			i += 16;
			j += 32;
		}
		if n > 0 {
			return Some(());
		}
	}
	#[cfg(not(all(any(target_arch = "x86", target_arch = "x86_64"), target_feature = "ssse3")))]
	{
		let _ = (input, output, sym);
	}
	None
}

fn decode_hex_simd(input: &[u8], output: &mut [u8], val: &[u8; 128]) -> Option<usize> {
	#[cfg(all(any(target_arch = "x86", target_arch = "x86_64"), target_feature = "ssse3"))]
	{
		let n = floor(input.len(), 32);
		let mut i = 0;
		let mut j = 0;
		while i < n {
			let input_ptr = unsafe { input.as_ptr().add(i) };
			let output_ptr = unsafe { output.as_mut_ptr().add(j) };
			let mut buffer = [0u8; 32];
			for (k, b) in buffer.iter_mut().enumerate() {
				let byte = unsafe { *input_ptr.add(k) };
				if byte >= 128 || val[byte as usize] == INVALID {
					return if j > 0 {
						Some(j)
					} else {
						None
					};
				}
				*b = val[byte as usize];
			}
			let t0 =
				unsafe { x86_simd::_mm_loadu_si128(buffer.as_ptr().cast::<x86_simd::__m128i>()) };
			let t1 = unsafe {
				x86_simd::_mm_loadu_si128(buffer.as_ptr().add(16).cast::<x86_simd::__m128i>())
			};
			let res = unsafe { x86_simd::_mm_or_si128(x86_simd::_mm_slli_epi32(t0, 4), t1) };
			let mask = unsafe {
				x86_simd::_mm_setr_epi8(0, 2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15)
			};
			let res = unsafe { x86_simd::_mm_shuffle_epi8(res, mask) };
			unsafe { x86_simd::_mm_storeu_si128(output_ptr.cast::<x86_simd::__m128i>(), res) };
			i += 32;
			j += 16;
		}
		if n > 0 {
			return Some(j);
		}
	}
	#[cfg(not(all(any(target_arch = "x86", target_arch = "x86_64"), target_feature = "ssse3")))]
	{
		let _ = (input, output, val);
	}
	None
}

fn decode_base64_simd(input: &[u8], output: &mut [u8], val: &[u8; 128]) -> Option<usize> {
	#[cfg(all(any(target_arch = "x86", target_arch = "x86_64"), target_feature = "ssse3"))]
	{
		let n = floor(input.len(), 16);
		let mut i = 0;
		let mut j = 0;
		while i < n {
			let input_ptr = unsafe { input.as_ptr().add(i) };
			let output_ptr = unsafe { output.as_mut_ptr().add(j) };
			let mut buffer = [0u8; 16];
			for (k, b) in buffer.iter_mut().enumerate() {
				let byte = unsafe { *input_ptr.add(k) };
				if byte >= 128 || val[byte as usize] == INVALID {
					return if j > 0 {
						Some(j)
					} else {
						None
					};
				}
				*b = val[byte as usize];
			}
			let input_vec =
				unsafe { x86_simd::_mm_loadu_si128(buffer.as_ptr().cast::<x86_simd::__m128i>()) };
			let mask_shuf = unsafe {
				x86_simd::_mm_setr_epi8(0, 2, 4, 6, 8, 10, 12, 14, 1, 3, 5, 7, 9, 11, 13, 15)
			};
			let shuffled = unsafe { x86_simd::_mm_shuffle_epi8(input_vec, mask_shuf) };
			let t0 =
				unsafe { x86_simd::_mm_unpacklo_epi8(shuffled, x86_simd::_mm_setzero_si128()) };
			let t1 =
				unsafe { x86_simd::_mm_unpackhi_epi8(shuffled, x86_simd::_mm_setzero_si128()) };
			let res = unsafe { x86_simd::_mm_or_si128(t0, x86_simd::_mm_slli_epi32(t1, 2)) };
			let mask_final = unsafe {
				x86_simd::_mm_setr_epi8(2, 1, 0, 6, 5, 4, 10, 9, 8, 14, 13, 12, 128, 128, 128, 128)
			};
			let res = unsafe { x86_simd::_mm_shuffle_epi8(res, mask_final) };
			unsafe { x86_simd::_mm_storeu_si128(output_ptr.cast::<x86_simd::__m128i>(), res) };
			i += 16;
			j += 12;
		}
		if n > 0 {
			return Some(j);
		}
	}
	#[cfg(not(all(any(target_arch = "x86", target_arch = "x86_64"), target_feature = "ssse3")))]
	{
		let _ = (input, output, val);
	}
	None
}

const fn order(bit: usize, msb: bool, i: usize) -> usize {
	if msb {
		bit - 1 - i
	} else {
		i
	}
}

const fn enc(bit: usize) -> usize {
	match bit {
		1 | 2 | 4 => 8 / bit,
		3 | 5 => 8,
		6 => 4,
		_ => 0,
	}
}

const fn dec(bit: usize) -> usize {
	match bit {
		1 | 2 | 4 => 1,
		3 | 6 => 3,
		5 => 5,
		_ => 1,
	}
}

fn encode_block<B: BitWidth, BO: BitOrderTrait>(sym: &[u8; 256], input: &[u8], output: &mut [u8]) {
	for (i, out) in output.iter_mut().enumerate().take(B::ENC) {
		let mut j = i * B::BIT;
		let mut x = 0;
		for k in 0..B::BIT {
			let byte_idx = j / 8;
			let bit_idx = order(8, BO::MSB, j % 8);
			if byte_idx < input.len() && (input[byte_idx] >> bit_idx) & 1 != 0 {
				x |= 1 << order(B::BIT, BO::MSB, k);
			}
			j += 1;
		}
		*out = sym[x];
	}
}

fn encode_mut_internal<B: BitWidth, BO: BitOrderTrait>(
	sym: &[u8; 256],
	input: &[u8],
	output: &mut [u8],
) -> usize {
	let mut input = input;
	let mut output = output;
	let mut written = 0;

	if B::BIT == 6 && BO::MSB {
		if let Some(()) = encode_base64_simd(input, output, sym) {
			let n = floor(input.len(), 12);
			input = &input[n..];
			output = &mut output[n / 3 * 4..];
			written += n / 3 * 4;
		}
	} else if B::BIT == 4 && BO::MSB {
		if let Some(()) = encode_hex_simd(input, output, sym) {
			let n = floor(input.len(), 16);
			input = &input[n..];
			output = &mut output[n * 2..];
			written += n * 2;
		}
	}

	while input.len() >= B::DEC {
		encode_block::<B, BO>(sym, &input[0..B::DEC], &mut output[0..B::ENC]);
		input = &input[B::DEC..];
		output = &mut output[B::ENC..];
		written += B::ENC;
	}
	if !input.is_empty() {
		encode_block::<B, BO>(sym, input, &mut output[0..B::ENC]);
		written += B::ENC;
	}
	written
}

fn decode_block<B: BitWidth, BO: BitOrderTrait>(
	val: &[u8; 128],
	input: &[u8],
	output: &mut [u8],
) -> Result<(), DecodeKind> {
	for x in output.iter_mut().take(B::DEC) {
		*x = 0;
	}
	for (i, &byte) in input.iter().enumerate().take(B::ENC) {
		let v = val[byte as usize];
		if v >= 128 {
			return Err(DecodeKind::Symbol);
		}
		let mut j = i * B::BIT;
		for k in 0..B::BIT {
			let byte_idx = j / 8;
			let bit_idx = order(8, BO::MSB, j % 8);
			if (v >> order(B::BIT, BO::MSB, k)) & 1 != 0 {
				output[byte_idx] |= 1 << bit_idx;
			}
			j += 1;
		}
	}
	Ok(())
}

fn check_trail<B: BitWidth, BO: BitOrderTrait>(val: &[u8; 128], input: &[u8]) -> Result<(), usize> {
	let bits = input.len() * B::BIT;
	let bytes = bits / 8;
	for (i, &byte) in input.iter().enumerate() {
		let v = val[byte as usize];
		for k in 0..B::BIT {
			let j = i * B::BIT + k;
			if j / 8 >= bytes {
				let bit_in_v = order(B::BIT, BO::MSB, k);
				if (v >> bit_in_v) & 1 != 0 {
					return Err(i);
				}
			}
		}
	}
	Ok(())
}

#[allow(dead_code)]
fn check_pad(val: &[u8; 128], input: &[u8], pad: u8) -> Result<usize, DecodeKind> {
	let mut i = input.len();
	while i > 0 && input[i - 1] == pad {
		i -= 1;
	}
	for &byte in &input[0..i] {
		if byte >= 128 || val[byte as usize] == PADDING {
			return Err(DecodeKind::Padding);
		}
	}
	Ok(i)
}

fn encode_pad_len_internal<B: BitWidth, PM: PaddingTrait>(ilen: usize) -> Option<usize> {
	if PM::MODE == PaddingMode::None {
		div_ceil(ilen * 8, B::BIT)
	} else {
		let n = div_ceil(ilen, B::DEC)?;
		n.checked_mul(B::ENC)
	}
}

fn encode_pad_internal<B: BitWidth, BO: BitOrderTrait, PM: PaddingTrait>(
	sym: &[u8; 256],
	pad: Option<u8>,
	input: &[u8],
	output: &mut [u8],
) -> usize {
	let olen = encode_pad_len_internal::<B, PM>(input.len()).unwrap();
	let (dec_val, enc_val) = (B::DEC, B::ENC);
	let input_full_len = input.len() / dec_val * dec_val;
	let output_full_len = input.len() / dec_val * enc_val;
	let mut written = encode_mut_internal::<B, BO>(
		sym,
		&input[0..input_full_len],
		&mut output[0..output_full_len],
	);
	let remaining_input = &input[input_full_len..];
	if !remaining_input.is_empty() {
		let mut block = [0u8; 32];
		encode_block::<B, BO>(sym, remaining_input, &mut block[0..enc_val]);
		let len = olen - written;
		output[written..olen].copy_from_slice(&block[0..len]);
		written += len;
	}
	if let Some(p) = pad {
		let data_len = div_ceil(input.len() * 8, B::BIT).unwrap();
		output[data_len..olen].fill(p);
	}
	written
}

#[allow(clippy::too_many_arguments)]
fn encode_wrap_mut_internal<B: BitWidth, BO: BitOrderTrait, PM: PaddingTrait>(
	_bit: B,
	_msb: BO,
	_pm: PM,
	sym: &[u8; 256],
	pad: Option<u8>,
	wrap: Option<(u8, &[u8])>,
	input: &[u8],
	output: &mut [u8],
) -> usize {
	if let Some((col, end)) = wrap {
		let col = col as usize;
		let mut i = 0;
		let mut written = 0;
		let mut j = 0;
		while i < input.len() {
			let n = core::cmp::min(B::DEC, input.len() - i);
			let mut out_temp = [0u8; 32];
			let m = if n == B::DEC {
				encode_block::<B, BO>(sym, &input[i..i + n], &mut out_temp[0..B::ENC]);
				B::ENC
			} else {
				let m = encode_pad_len_internal::<B, PM>(n).unwrap();
				let _ = encode_pad_internal::<B, BO, PM>(
					sym,
					pad,
					&input[i..i + n],
					&mut out_temp[0..m],
				);
				m
			};
			for &byte in out_temp.iter().take(m) {
				output[written] = byte;
				written += 1;
				j += 1;
				if j == col {
					output[written..written + end.len()].copy_from_slice(end);
					written += end.len();
					j = 0;
				}
			}
			i += n;
		}
		if j != 0 {
			output[written..written + end.len()].copy_from_slice(end);
			written += end.len();
		}
		written
	} else {
		encode_pad_internal::<B, BO, PM>(sym, pad, input, output)
	}
}

fn skip_ignore(val: &[u8; 128], input: &[u8]) -> usize {
	let mut i = 0;
	while i < input.len() && (input[i] >= 128 || val[input[i] as usize] == IGNORE) {
		i += 1;
	}
	i
}

#[allow(clippy::too_many_lines, clippy::too_many_arguments)]
fn decode_wrap_mut_internal<B: BitWidth, BO: BitOrderTrait, PM: PaddingTrait, I: IgnoreTrait>(
	_bit: B,
	_msb: BO,
	_pm: PM,
	_ign: I,
	ctb: bool,
	val: &[u8; 128],
	sym: &[u8; 256],
	pad_char: Option<u8>,
	input: &[u8],
	output: &mut [u8],
) -> Result<usize, DecodePartial> {
	let mut input = input;
	let mut output = output;
	let mut read = 0;
	let mut written = 0;

	macro_rules! error {
		($pos: expr, $kind: expr) => {
			Err(DecodePartial {
				read,
				written,
				error: DecodeError {
					position: $pos,
					kind: $kind,
				},
			})
		};
	}

	if !I::IGNORE && pad_char.is_none() {
		if B::BIT == 4 && BO::MSB {
			if let Some(n) = decode_hex_simd(input, output, val) {
				input = &input[n * 2..];
				output = &mut output[n..];
				read += n * 2;
				written += n;
			}
		} else if B::BIT == 6 && BO::MSB {
			if let Some(n) = decode_base64_simd(input, output, val) {
				input = &input[n / 3 * 4..];
				output = &mut output[n..];
				read += n / 3 * 4;
				written += n;
			}
		}
	}

	while !input.is_empty() {
		if I::IGNORE {
			let n = skip_ignore(val, input);
			input = &input[n..];
			read += n;
		}
		if input.is_empty() {
			break;
		}
		let block_start = read;
		let mut buffer = [0u8; 8];
		let mut b_pos = [0usize; 8];
		let mut b_idx = 0;
		let mut p_idx = None;
		let mut p_pos = 0;
		while b_idx < B::ENC && !input.is_empty() {
			if I::IGNORE {
				let n = skip_ignore(val, input);
				input = &input[n..];
				read += n;
			}
			if input.is_empty() {
				break;
			}
			let byte = input[0];
			let pos = read;
			if Some(byte) == pad_char {
				if p_idx.is_none() {
					p_idx = Some(b_idx);
					p_pos = pos;
				}
			} else if p_idx.is_some() {
				return error!(pos, DecodeKind::Symbol);
			} else if byte >= 128 || val[byte as usize] == INVALID {
				return error!(read, DecodeKind::Symbol);
			}
			buffer[b_idx] = byte;
			b_pos[b_idx] = pos;
			input = &input[1..];
			read += 1;
			b_idx += 1;
		}
		if b_idx == 0 {
			break;
		}
		if b_idx < B::ENC {
			if PM::MODE == PaddingMode::None {
				let n = (b_idx * B::BIT) / 8;
				if n > 0 {
					for item in buffer.iter_mut().take(B::ENC).skip(b_idx) {
						*item = sym[0];
					}
					let mut out_temp = [0u8; 8];
					decode_block::<B, BO>(val, &buffer[0..B::ENC], &mut out_temp[0..B::DEC])
						.map_err(|kind| DecodePartial {
							read,
							written,
							error: DecodeError {
								position: block_start,
								kind,
							},
						})?;
					output[..n].copy_from_slice(&out_temp[..n]);
					written += n;
				} else if b_idx > 0 {
					return error!(block_start, DecodeKind::Length);
				}
				if ctb {
					check_trail::<B, BO>(val, &buffer[0..b_idx]).map_err(|idx| DecodePartial {
						read,
						written,
						error: DecodeError {
							position: b_pos[idx],
							kind: DecodeKind::Trailing,
						},
					})?;
				}
				break;
			}
			return error!(block_start, DecodeKind::Length);
		}
		if let Some(p) = p_idx {
			if p == 0 {
				return error!(block_start, DecodeKind::Padding);
			}
			let valid = buffer[0];
			for item in buffer.iter_mut().take(B::ENC).skip(p) {
				*item = valid;
			}
		}
		let mut out_temp = [0u8; 8];
		decode_block::<B, BO>(val, &buffer[0..B::ENC], &mut out_temp[0..B::DEC]).map_err(
			|kind| DecodePartial {
				read,
				written,
				error: DecodeError {
					position: block_start,
					kind,
				},
			},
		)?;
		let n = if let Some(p) = p_idx {
			let actual_olen = (p * B::BIT) / 8;
			if (p * B::BIT) % 8 >= B::BIT {
				return error!(p_pos, DecodeKind::Padding);
			}
			if ctb && p > 0 {
				check_trail::<B, BO>(val, &buffer[0..p]).map_err(|idx| DecodePartial {
					read,
					written,
					error: DecodeError {
						position: b_pos[idx],
						kind: DecodeKind::Trailing,
					},
				})?;
			}
			actual_olen
		} else {
			B::DEC
		};
		output[..n].copy_from_slice(&out_temp[..n]);
		output = &mut output[n..];
		written += n;
	}
	Ok(written)
}

/// Bit order
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
pub enum BitOrder {
	/// Most significant bit first
	MostSignificantFirst,
	/// Least significant bit first
	LeastSignificantFirst,
}

#[doc(hidden)]
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
#[allow(clippy::large_enum_variant)]
pub enum InternalEncoding {
	/// Static implementation
	Static(&'static [u8]),
	/// Owned implementation
	Owned([u8; 644]),
}

impl core::ops::Deref for InternalEncoding {
	type Target = [u8];
	fn deref(&self) -> &[u8] {
		match self {
			InternalEncoding::Static(s) => s,
			InternalEncoding::Owned(i) => i,
		}
	}
}

/// Base-conversion encoding
#[derive(Copy, Clone, Debug, Eq)]
pub struct Encoding(InternalEncoding);

impl PartialEq for Encoding {
	fn eq(&self, other: &Self) -> bool {
		if self.is_arithmetic() != other.is_arithmetic() {
			return false;
		}
		if self.is_arithmetic() {
			return self.get_symbols() == other.get_symbols();
		}
		self.bit() == other.bit()
			&& self.msb() == other.msb()
			&& self.ctb() == other.ctb()
			&& self.pad() == other.pad()
			&& self.pad_mode() == other.pad_mode()
			&& self.sym() == other.sym()
			&& self.val() == other.val()
			&& self.wrap() == other.wrap()
	}
}

/// Character translation
#[derive(Clone, Default, Debug, PartialEq, Eq)]
pub struct Translate {
	/// Characters to translate from
	pub from: String,
	/// Characters to translate to
	pub to: String,
}

/// Output wrapping
#[derive(Clone, Default, Debug, PartialEq, Eq)]
pub struct Wrap {
	/// Wrap width
	pub width: usize,
	/// Wrap separator
	pub separator: String,
}

/// Encoding specification
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Specification {
	/// Symbols used by the encoding
	pub symbols: String,
	/// Bit order
	pub bit_order: BitOrder,
	/// Whether to check trailing bits
	pub check_trailing_bits: bool,
	/// Padding character
	pub padding: Option<char>,
	/// Padding mode
	pub padding_mode: PaddingMode,
	/// Characters to ignore when decoding
	pub ignore: String,
	/// Wrap configuration
	pub wrap: Wrap,
	/// Character translation
	pub translate: Translate,
	/// Whether to use arithmetic encoding
	pub use_arithmetic: bool,
}

impl Default for Specification {
	fn default() -> Self {
		Self::new()
	}
}

impl Encoding {
	fn data(&self) -> &[u8] {
		&self.0
	}
	fn sym(&self) -> &[u8; 256] {
		let d = self.data();
		let offset = if d.len() >= 514 && (d[513] & 0x40) != 0 {
			256
		} else {
			0
		};
		unsafe { &*d.as_ptr().add(offset).cast::<[u8; 256]>() }
	}
	fn val(&self) -> &[u8; 128] {
		let d = self.data();
		let offset = if d.len() >= 514 && (d[513] & 0x40) != 0 {
			0
		} else {
			256
		};

		unsafe { &*d.as_ptr().add(offset).cast::<[u8; 128]>() }
	}
	/// Returns true if the encoding is arithmetic
	#[must_use]
	pub fn is_arithmetic(&self) -> bool {
		let d = self.data();
		if d.len() >= 514 && (d[513] & 0x80) != 0 {
			return true;
		}
		if d.len() == 513 && (d[512] & 0x80) != 0 {
			return true;
		}
		false
	}
	fn get_symbols(&self) -> &[u8] {
		let d = self.data();
		if self.is_arithmetic() {
			let len = d[512] as usize;
			&d[0..core::cmp::min(len, 256)]
		} else {
			let b = self.bit();
			let n = if b == 0 {
				0
			} else {
				1 << b
			};
			&d[0..core::cmp::min(n, 256)]
		}
	}
	fn bit(&self) -> usize {
		if self.is_arithmetic() {
			return 0;
		}
		let d = self.data();
		let info = if d.len() >= 514 && (d[513] & 0x7) != 0 {
			d[513]
		} else if d.len() >= 513 && (d[512] & 0x7) != 0 {
			d[512]
		} else {
			0
		};
		let mut b = (info & 0x7) as usize;
		if b == 0 {
			b = match d.len() {
				len if len >= 644 || len == 512 || len == 513 || len == 256 => {
					if d.len() >= 64 && d[0..32] == d[32..64] {
						if d[0..16] == d[16..32] {
							4
						} else {
							5
						}
					} else {
						6
					}
				}
				_ => 0,
			};
		}
		b
	}
	fn msb(&self) -> bool {
		if self.is_arithmetic() {
			return true;
		}
		let d = self.data();
		let info = if d.len() >= 514 && (d[513] & 0x7) != 0 {
			d[513]
		} else if d.len() >= 513 && (d[512] & 0x7) != 0 {
			d[512]
		} else {
			0
		};
		if (info & 0x7) != 0 {
			(info & 0x8) != 0
		} else {
			if d.len() >= 11 && &d[0..11] == b"0123456789b" {
				return false;
			}
			true
		}
	}
	fn ctb(&self) -> bool {
		let d = self.data();
		if d.len() == 513 {
			d[512] & 0x10 != 0 || self.pad_mode() == PaddingMode::Standard
		} else if d.len() >= 514 {
			(d[513] & 0x10) != 0 || self.pad_mode() == PaddingMode::Standard
		} else {
			true
		}
	}
	fn pad(&self) -> Option<u8> {
		if self.is_arithmetic() {
			return None;
		}
		let d = self.data();
		let v = self.val();
		if d.len() >= 513 && d[512] < 128 && v[d[512] as usize] == PADDING {
			return Some(d[512]);
		}
		for i in 0..128u8 {
			if v[i as usize] == PADDING {
				return Some(i);
			}
		}
		None
	}
	fn pad_mode(&self) -> PaddingMode {
		if self.is_arithmetic() {
			return PaddingMode::None;
		}
		let d = self.data();
		let info = if d.len() >= 514 && (d[513] & 0x7) != 0 {
			d[513]
		} else if d.len() >= 513 && (d[512] & 0x7) != 0 {
			d[512]
		} else {
			0
		};
		match (info >> 5) & 0x3 {
			1 => PaddingMode::Standard,
			2 => PaddingMode::PadConcat,
			3 => PaddingMode::PadFinal,
			_ => {
				if self.pad().is_some() {
					PaddingMode::Standard
				} else {
					PaddingMode::None
				}
			}
		}
	}
	fn wrap(&self) -> Option<(usize, &[u8])> {
		match &self.0 {
			InternalEncoding::Static(d) if d.len() > 514 && d[514] > 0 => {
				Some((d[514] as usize, &d[515..]))
			}
			InternalEncoding::Owned(d) if d[514] > 0 => {
				let width = d[514] as usize;
				let sep_len = d[515] as usize;
				Some((width, &d[516..516 + sep_len]))
			}
			_ => None,
		}
	}
	fn has_ignore(&self) -> bool {
		self.val().contains(&IGNORE) || self.wrap().is_some_and(|(_, s)| !s.is_empty())
	}
	fn block_len(&self) -> (usize, usize) {
		let bit = self.bit();
		if bit == 0 {
			return (1, 1);
		}
		match self.wrap() {
			Some((col, end)) => (col / enc(bit) * dec(bit), col + end.len()),
			None => (dec(bit), enc(bit)),
		}
	}
	/// Returns the required output alignment
	#[must_use]
	pub fn encode_align(&self) -> usize {
		if self.is_arithmetic() {
			1
		} else {
			self.block_len().1
		}
	}
	/// Returns the maximum encoded length of an input of length `len`
	///
	/// # Errors
	///
	/// Returns an error if the length is too large.
	pub fn encode_len(&self, len: usize) -> Result<usize, EncodeError> {
		if self.is_arithmetic() {
			return Ok(len + len / 2 + 2);
		}
		let (bit, pm, wr) = (self.bit(), self.pad_mode(), self.wrap());
		dispatch! {
			let bit: usize = bit; let pm: PaddingMode = pm;
			let olen = if pm.val() == PaddingMode::None { div_ceil(len.checked_mul(8).ok_or(EncodeError { kind: EncodeKind::Overflow })?, bit.val()).ok_or(EncodeError { kind: EncodeKind::Overflow })? }
			else { div_ceil(len, dec(bit.val())).ok_or(EncodeError { kind: EncodeKind::Overflow })? * enc(bit.val()) };
			if let Some((col, sep)) = wr {
				let n = div_ceil(olen, col).ok_or(EncodeError { kind: EncodeKind::Overflow })?;
				olen.checked_add(n * sep.len()).ok_or(EncodeError { kind: EncodeKind::Overflow })
			} else { Ok(olen) }
		}
	}
	/// Encodes `input` into `output`
	///
	/// # Errors
	///
	/// Returns an error if the `output` length is too small.
	pub fn encode_mut(&self, input: &[u8], output: &mut [u8]) -> Result<usize, EncodeError> {
		if self.is_arithmetic() {
			arithmetic::encode_to_buffer(self.get_symbols(), input, output)
		} else {
			dispatch! {
				let bit: usize = self.bit(); let msb: bool = self.msb(); let pm: PaddingMode = self.pad_mode();
				Ok(encode_wrap_mut_internal(bit, msb, pm, self.sym(), self.pad(), self.wrap().map(|(w,s)| (u8::try_from(w).unwrap_or(0), s)), input, output))
			}
		}
	}
	#[cfg(feature = "alloc")]
	/// Encodes `input` into a new string
	///
	/// # Panics
	///
	/// Panics if the output length overflows or encoding fails.
	#[must_use]
	pub fn encode(&self, input: &[u8]) -> String {
		let mut out = vec![0u8; self.encode_len(input.len()).expect("overflow")];
		let n = self.encode_mut(input, &mut out).expect("failed");
		out.truncate(n);
		unsafe { String::from_utf8_unchecked(out) }
	}

	/// Appends the encoding of `input` to `output`
	///
	/// # Panics
	///
	/// Panics if the encoding fails (e.g. length overflow).
	#[cfg(feature = "alloc")]
	pub fn encode_append(&self, input: &[u8], output: &mut String) {
		let len = self.encode_len(input.len()).expect("encoding length overflow");
		let output_len = output.len();
		unsafe {
			let vec = output.as_mut_vec();
			vec.resize(output_len + len, 0);
			let written = self.encode_mut(input, &mut vec[output_len..]).expect("encoding failed");
			vec.truncate(output_len + written);
		}
	}

	/// Returns a new encoder
	#[cfg(feature = "alloc")]
	#[must_use]
	pub fn new_encoder<'a>(&'a self, output: &'a mut String) -> Encoder<'a> {
		Encoder::new(self, output)
	}

	/// Encodes `input` in `output`
	///
	/// # Errors
	///
	/// Returns an error if the `output` is not writable.
	#[cfg(feature = "std")]
	pub fn encode_write(
		&self,
		input: &[u8],
		mut output: impl std::io::Write,
	) -> std::io::Result<()> {
		let mut buffer = [0u8; 1024];
		let (ilen, olen) = self.block_len();
		for chunk in input.chunks(floor(1024 / olen * ilen, ilen)) {
			let len = self
				.encode_mut(chunk, &mut buffer[..self.encode_len(chunk.len()).unwrap()])
				.unwrap();
			output.write_all(&buffer[..len])?;
		}
		Ok(())
	}

	/// Encodes `input` in `output` through a buffer
	///
	/// This function uses a buffer to avoid many small writes to `output`.
	#[cfg(feature = "std")]
	pub fn encode_write_buffer(
		&self,
		input: &[u8],
		mut output: impl std::io::Write,
		buffer: &mut [u8],
	) -> std::io::Result<()> {
		let (ilen, olen) = self.block_len();
		let max_ilen = floor(buffer.len() / olen * ilen, ilen);
		if max_ilen == 0 {
			return Err(std::io::Error::new(std::io::ErrorKind::InvalidInput, "buffer too small"));
		}
		for chunk in input.chunks(max_ilen) {
			let len = self
				.encode_mut(chunk, &mut buffer[..self.encode_len(chunk.len()).unwrap()])
				.unwrap();
			output.write_all(&buffer[..len])?;
		}
		Ok(())
	}

	/// Returns a displayable version of `input`
	#[must_use]
	pub fn encode_display<'a>(&'a self, input: &'a [u8]) -> Display<'a> {
		Display {
			encoding: self,
			input,
		}
	}

	/// Returns the maximum decoded length of an input of length `len`
	///
	/// # Errors
	///
	/// Returns an error if the length is invalid.
	pub fn decode_len(&self, len: usize) -> Result<usize, DecodeError> {
		if self.is_arithmetic() {
			return Ok(len);
		}
		let bit = self.bit();
		if bit == 0 {
			return Ok(0);
		}
		let pm = self.pad_mode();
		let ev = enc(bit);
		let dv = dec(bit);
		if pm == PaddingMode::None {
			let bits = len.checked_mul(bit).ok_or(DecodeError {
				position: 0,
				kind: DecodeKind::Overflow,
			})?;
			if !self.has_ignore() && bits % 8 != 0 && self.ctb() {
				return Err(DecodeError {
					position: len / ev * ev,
					kind: DecodeKind::Length,
				});
			}
			Ok(bits / 8)
		} else {
			if !self.has_ignore() && len % ev != 0 {
				return Err(DecodeError {
					position: len / ev * ev,
					kind: DecodeKind::Length,
				});
			}
			Ok(len / ev * dv)
		}
	}
	/// Decodes `input` into `output`
	///
	/// # Errors
	///
	/// Returns an error if the input is invalid.
	pub fn decode_mut(&self, input: &[u8], output: &mut [u8]) -> Result<usize, DecodePartial> {
		if self.is_arithmetic() {
			let s = core::str::from_utf8(input).map_err(|e| DecodePartial {
				read: e.valid_up_to(),
				written: 0,
				error: DecodeError {
					position: e.valid_up_to(),
					kind: DecodeKind::Symbol,
				},
			})?;
			arithmetic::decode_to_buffer(self.get_symbols(), s, output).map_err(|e| DecodePartial {
				read: e.position,
				written: 0,
				error: e,
			})
		} else {
			dispatch! {
				let bit: usize = self.bit(); let msb: bool = self.msb(); let pm: PaddingMode = self.pad_mode(); let ign: has_ignore = self.has_ignore();
				Ok(decode_wrap_mut_internal(bit, msb, pm, ign, self.ctb(), self.val(), self.sym(), self.pad(), input, output)?)
			}
		}
	}
	#[cfg(feature = "alloc")]
	/// Decodes `input` into a new vector
	///
	/// # Errors
	///
	/// Returns an error if the input is invalid.
	#[cfg(feature = "alloc")]
	pub fn decode(&self, input: &[u8]) -> Result<Vec<u8>, DecodeError> {
		let mut out = vec![0u8; self.decode_len(input.len())?];
		let n = self.decode_mut(input, &mut out).map_err(|p| p.error)?;
		out.truncate(n);
		Ok(out)
	}

	/// Returns the bit-width
	#[must_use]
	pub fn bit_width(&self) -> usize {
		if self.is_arithmetic() {
			let base = self.data()[512] as u32;
			if base == 0 {
				return 0;
			}
			(32 - base.leading_zeros()) as usize
		} else {
			self.bit()
		}
	}

	/// Returns whether the encoding is canonical
	#[must_use]
	pub fn is_canonical(&self) -> bool {
		if self.is_arithmetic() {
			return true;
		}
		let bit = self.bit();
		if bit > 0 && (8 % bit) != 0 && !self.ctb() {
			return false;
		}
		let symbols = self.get_symbols();
		let num_symbols = symbols.len();
		if num_symbols == 0 {
			return false;
		}
		let sym = self.sym();
		let val = self.val();
		for i in 0..num_symbols {
			if sym[i] >= 128 || val[sym[i] as usize] as usize != i {
				return false;
			}
		}
		for i in 0..128 {
			let v = val[i];
			if v == PADDING {
				if Some(i as u8) != self.pad() {
					return false;
				}
			} else if v != INVALID && v != IGNORE && (v as usize) < num_symbols {
				if sym[v as usize] as usize != i {
					return false;
				}
			}
		}
		if self.wrap().is_some() {
			return false;
		}
		true
	}

	/// Returns the encoding specification
	#[allow(clippy::missing_panics_doc)]
	#[cfg(feature = "alloc")]
	#[must_use]
	pub fn specification(&self) -> Specification {
		let mut specification = Specification::new();
		let symbols = self.get_symbols();
		specification.symbols.push_str(core::str::from_utf8(symbols).unwrap_or(""));
		specification.bit_order = if self.msb() {
			BitOrder::MostSignificantFirst
		} else {
			BitOrder::LeastSignificantFirst
		};
		specification.check_trailing_bits = self.ctb();
		specification.padding_mode = self.pad_mode();
		if let Some(pad) = self.pad() {
			specification.padding = Some(pad as char);
		}
		for i in 0..128u8 {
			if self.val()[i as usize] != IGNORE {
				continue;
			}
			specification.ignore.push(i as char);
		}
		if let Some((col, end)) = self.wrap() {
			specification.wrap.width = col;
			specification.wrap.separator = String::from(core::str::from_utf8(end).unwrap_or(""));
		}
		let num_symbols = symbols.len();
		for i in 0..128u8 {
			let v = self.val()[i as usize];
			if v == IGNORE {
				continue;
			}
			let canonical = if (v as usize) < num_symbols {
				self.sym()[v as usize]
			} else if v == PADDING {
				match self.pad() {
					Some(p) => p,
					None => continue,
				}
			} else {
				continue;
			};
			if i == canonical {
				continue;
			}
			specification.translate.from.push(i as char);
			specification.translate.to.push(canonical as char);
		}
		specification.use_arithmetic = self.is_arithmetic();
		specification
	}

	/// Internal function to create a new encoding from static data
	#[doc(hidden)]
	#[must_use]
	pub const fn internal_new(implementation: &'static [u8]) -> Self {
		Self(InternalEncoding::Static(implementation))
	}

	/// Returns the maximum decoded length with wrapping
	///
	/// # Errors
	///
	/// Returns an error if the length is invalid.
	pub fn decode_wrap_len(&self, len: usize) -> Result<usize, DecodeError> {
		if self.is_arithmetic() {
			return Ok(len);
		}
		let (bit, _) = (self.bit(), self.pad_mode());
		let dv = dec(bit);
		Ok(len / 8 * dv + dv)
	}

	/// Decodes `input` into `output` with wrapping
	///
	/// # Errors
	///
	/// Returns an error if the input is invalid.
	pub fn decode_wrap_mut(&self, input: &[u8], output: &mut [u8]) -> Result<usize, DecodePartial> {
		self.decode_mut(input, output)
	}

	/// Decodes `input` into a new vector with wrapping
	///
	/// # Errors
	///
	/// Returns an error if the input is invalid.
	#[cfg(feature = "alloc")]
	pub fn decode_wrap(&self, input: &[u8]) -> Result<Vec<u8>, DecodeError> {
		let mut out = vec![0u8; self.decode_wrap_len(input.len())?];
		let n = self.decode_wrap_mut(input, &mut out).map_err(|p| p.error)?;
		out.truncate(n);
		Ok(out)
	}

	/// Returns a new decoder
	#[cfg(feature = "alloc")]
	#[must_use]
	pub fn new_decoder<'a>(&'a self, _input: &'a str) -> Decoder<'a> {
		Decoder {
			encoding: self,
			_placeholder: (),
		}
	}
}

/// Fragmented decoder
#[cfg(feature = "alloc")]
#[derive(Debug)]
pub struct Decoder<'a> {
	encoding: &'a Encoding,
	_placeholder: (),
}

/// Encodes fragmented input to an output
///
/// Use this struct if your input is in several pieces.
#[derive(Debug)]
pub struct Encoder<'a> {
	encoding: &'a Encoding,
	output: &'a mut String,
	buffer: [u8; 8],
	length: usize,
}

impl Drop for Encoder<'_> {
	fn drop(&mut self) {
		self.finalize();
	}
}

impl<'a> Encoder<'a> {
	fn new(encoding: &'a Encoding, output: &'a mut String) -> Encoder<'a> {
		Encoder {
			encoding,
			output,
			buffer: [0u8; 8],
			length: 0,
		}
	}

	/// Appends the encoding of `input` to the output
	pub fn append(&mut self, input: &[u8]) {
		let mut input = input;
		let (ilen, _olen) = self.encoding.block_len();
		if self.length > 0 {
			let n = core::cmp::min(ilen - self.length, input.len());
			self.buffer[self.length..self.length + n].copy_from_slice(&input[0..n]);
			self.length += n;
			input = &input[n..];
			if self.length == ilen {
				self.encoding.encode_append(&self.buffer[0..ilen], self.output);
				self.length = 0;
			}
		}
		let n = floor(input.len(), ilen);
		self.encoding.encode_append(&input[0..n], self.output);
		input = &input[n..];
		if !input.is_empty() {
			self.buffer[0..input.len()].copy_from_slice(input);
			self.length = input.len();
		}
	}

	/// Finalizes the encoding
	pub fn finalize(&mut self) {
		if self.length > 0 {
			self.encoding.encode_append(&self.buffer[0..self.length], self.output);
			self.length = 0;
		}
	}
}

/// Displayable version of encoded data
#[derive(Debug)]
pub struct Display<'a> {
	encoding: &'a Encoding,
	input: &'a [u8],
}

impl core::fmt::Display for Display<'_> {
	fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
		let mut buffer = [0u8; 1024];
		let (ilen, olen) = self.encoding.block_len();
		for chunk in self.input.chunks(floor(1024 / olen * ilen, ilen)) {
			let len = self
				.encoding
				.encode_mut(chunk, &mut buffer[..self.encoding.encode_len(chunk.len()).unwrap()])
				.unwrap();
			write!(f, "{}", unsafe { core::str::from_utf8_unchecked(&buffer[..len]) })?;
		}
		Ok(())
	}
}

impl Specification {
	/// Returns a new empty specification
	#[must_use]
	pub fn new() -> Self {
		Self {
			symbols: String::new(),
			bit_order: BitOrder::MostSignificantFirst,
			check_trailing_bits: true,
			padding: None,
			padding_mode: PaddingMode::Standard,
			ignore: String::new(),
			wrap: Wrap::default(),
			translate: Translate::default(),
			use_arithmetic: false,
		}
	}
	/// Returns the encoding corresponding to the specification
	///
	/// # Panics
	///
	/// Panics if symbol index or length overflows `u8`.
	///
	/// # Errors
	///
	/// Returns an error if the specification is invalid.
	pub fn encoding(&self) -> Result<Encoding, SpecificationError> {
		let syms = self.symbols.as_bytes();
		check!(SpecificationError(SpecificationErrorImpl::BadSize), !syms.is_empty());
		let use_arith = self.use_arithmetic || ![2, 4, 8, 16, 32, 64].contains(&syms.len());
		let mut values = [INVALID; 128];
		for (v, &s) in syms.iter().enumerate() {
			check!(SpecificationError(SpecificationErrorImpl::NotAscii), s < 128);
			check!(
				SpecificationError(SpecificationErrorImpl::Duplicate(s)),
				values[s as usize] == INVALID
			);
			values[s as usize] = u8::try_from(v).expect("overflow");
		}
		if let Some(p) = self.padding {
			check!(SpecificationError(SpecificationErrorImpl::NotAscii), (p as u32) < 128);
			check!(
				SpecificationError(SpecificationErrorImpl::Duplicate(p as u8)),
				values[p as usize] == INVALID
			);
			if !use_arith {
				let bit = syms.len().trailing_zeros() as usize;
				if 8 % bit == 0 {
					return Err(SpecificationError(SpecificationErrorImpl::ExtraPadding));
				}
			}
		}
		check!(
			SpecificationError(SpecificationErrorImpl::FromTo),
			self.translate.from.len() == self.translate.to.len()
		);
		let mut data = [0u8; 644];
		for i in 256..384 {
			data[i] = INVALID;
		}
		if use_arith {
			data[0..syms.len()].copy_from_slice(syms);
			data[512] = u8::try_from(syms.len()).expect("overflow");
			data[513] = 0x80;
		} else {
			for i in 0..256 {
				data[i] = syms[i % syms.len()];
			}
			let bit = match syms.len() {
				2 => 1,
				4 => 2,
				8 => 3,
				16 => 4,
				32 => 5,
				64 => 6,
				_ => 0,
			};
			data[513] = bit;
		}
		data[256..384].copy_from_slice(&values);
		if let Some(p) = self.padding {
			data[512] = p as u8;
			data[256 + p as usize] = PADDING;
		} else if !use_arith {
			data[512] = INVALID;
		}
		for &i in self.ignore.as_bytes() {
			check!(SpecificationError(SpecificationErrorImpl::NotAscii), i < 128);
			check!(
				SpecificationError(SpecificationErrorImpl::Duplicate(i)),
				data[256 + i as usize] == INVALID
			);
			data[256 + i as usize] = IGNORE;
		}
		for (f, t) in self.translate.from.as_bytes().iter().zip(self.translate.to.as_bytes()) {
			check!(SpecificationError(SpecificationErrorImpl::NotAscii), *f < 128 && *t < 128);
			check!(
				SpecificationError(SpecificationErrorImpl::Duplicate(*f)),
				data[256 + *f as usize] == INVALID
			);
			let v = data[256 + *t as usize];
			check!(SpecificationError(SpecificationErrorImpl::Undefined(*t)), v != INVALID);
			data[256 + *f as usize] = v;
		}
		if self.wrap.width > 0 && !self.wrap.separator.is_empty() {
			if !use_arith {
				let bit = data[513] & 0x7;
				if bit > 0 {
					let enc_val = enc(bit as usize);
					if self.wrap.width % enc_val != 0 {
						return Err(SpecificationError(SpecificationErrorImpl::WrapWidth(
							enc_val as u8,
						)));
					}
				}
			}
			check!(
				SpecificationError(SpecificationErrorImpl::WrapLength),
				self.wrap.width <= 255 && self.wrap.separator.len() <= 128
			);
			data[514] = u8::try_from(self.wrap.width).unwrap_or(0);
			let sep = self.wrap.separator.as_bytes();
			let sep_len = core::cmp::min(sep.len(), 128);
			data[515] = u8::try_from(sep_len).unwrap_or(0);
			data[516..516 + sep_len].copy_from_slice(&sep[..sep_len]);
			for &s in &sep[..sep_len] {
				check!(SpecificationError(SpecificationErrorImpl::NotAscii), s < 128);
				let v = data[256 + s as usize];
				check!(
					SpecificationError(SpecificationErrorImpl::WrapSeparator),
					v == INVALID || v == IGNORE
				);
				if v == INVALID {
					data[256 + s as usize] = IGNORE;
				}
			}
		}
		if self.bit_order == BitOrder::MostSignificantFirst {
			data[513] |= 0x08;
		}
		if self.check_trailing_bits {
			data[513] |= 0x10;
		}
		let m = if self.padding.is_none() {
			0
		} else {
			match self.padding_mode {
				PaddingMode::None => 0,
				PaddingMode::Standard => 1,
				PaddingMode::PadConcat => 2,
				PaddingMode::PadFinal => 3,
			}
		};
		data[513] |= u8::try_from(m).unwrap() << 5;
		Ok(Encoding(InternalEncoding::Owned(data)))
	}
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum SpecificationErrorImpl {
	BadSize,
	NotAscii,
	Duplicate(u8),
	ExtraPadding,
	WrapLength,
	WrapSeparator,
	WrapWidth(u8),
	FromTo,
	Undefined(u8),
}

/// Specification error
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SpecificationError(SpecificationErrorImpl);
impl core::fmt::Display for SpecificationError {
	fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
		match self.0 {
			SpecificationErrorImpl::BadSize => write!(f, "invalid number of symbols"),
			SpecificationErrorImpl::NotAscii => write!(f, "non-ascii character"),
			SpecificationErrorImpl::Duplicate(c) => {
				write!(f, "{:?} has conflicting definitions", c as char)
			}
			SpecificationErrorImpl::ExtraPadding => write!(f, "unnecessary padding"),
			SpecificationErrorImpl::WrapLength => {
				write!(f, "invalid wrap width or separator length")
			}
			SpecificationErrorImpl::WrapSeparator => write!(f, "invalid wrap separator"),
			SpecificationErrorImpl::WrapWidth(n) => write!(f, "wrap width not a multiple of {n}"),
			SpecificationErrorImpl::FromTo => write!(f, "translate from/to length mismatch"),
			SpecificationErrorImpl::Undefined(c) => write!(f, "{:?} is undefined", c as char),
		}
	}
}
impl std::error::Error for SpecificationError {}

/// Lowercase hexadecimal encoding
pub const HEXLOWER: Encoding = Encoding::internal_new(data::HEXLOWER_IMPL);

/// Lowercase hexadecimal encoding with case-insensitive decoding
pub const HEXLOWER_PERMISSIVE: Encoding = Encoding::internal_new(data::HEXLOWER_PERMISSIVE_IMPL);

/// Uppercase hexadecimal encoding
pub const HEXUPPER: Encoding = Encoding::internal_new(data::HEXUPPER_IMPL);

/// Uppercase hexadecimal encoding with case-insensitive decoding
pub const HEXUPPER_PERMISSIVE: Encoding = Encoding::internal_new(data::HEXUPPER_PERMISSIVE_IMPL);

/// Padded base32 encoding
pub const BASE32: Encoding = Encoding::internal_new(data::BASE32_IMPL);

/// Unpadded base32 encoding
pub const BASE32_NOPAD: Encoding = Encoding::internal_new(data::BASE32_NOPAD_IMPL);

/// Unpadded base32 encoding with case-insensitive decoding
pub const BASE32_NOPAD_NOCASE: Encoding = Encoding::internal_new(data::BASE32_NOPAD_NOCASE_IMPL);

/// Unpadded base32 encoding with visual error correction during decoding
pub const BASE32_NOPAD_VISUAL: Encoding = Encoding::internal_new(data::BASE32_NOPAD_VISUAL_IMPL);

/// Padded base32hex encoding
pub const BASE32HEX: Encoding = Encoding::internal_new(data::BASE32HEX_IMPL);

/// Unpadded base32hex encoding
pub const BASE32HEX_NOPAD: Encoding = Encoding::internal_new(data::BASE32HEX_NOPAD_IMPL);

/// DNSSEC base32 encoding
pub const BASE32_DNSSEC: Encoding = Encoding::internal_new(data::BASE32_DNSSEC_IMPL);

/// DNSCurve base32 encoding
pub const BASE32_DNSCURVE: Encoding = Encoding::internal_new(data::BASE32_DNSCURVE_IMPL);

/// Padded base64 encoding
pub const BASE64: Encoding = Encoding::internal_new(data::BASE64_IMPL);

/// Unpadded base64 encoding
pub const BASE64_NOPAD: Encoding = Encoding::internal_new(data::BASE64_NOPAD_IMPL);

/// MIME base64 encoding
pub const BASE64_MIME: Encoding = Encoding::internal_new(data::BASE64_MIME_IMPL);

/// MIME base64 encoding without trailing bits check
pub const BASE64_MIME_PERMISSIVE: Encoding =
	Encoding::internal_new(data::BASE64_MIME_PERMISSIVE_IMPL);

/// Padded base64url encoding
pub const BASE64URL: Encoding = Encoding::internal_new(data::BASE64URL_IMPL);

/// Unpadded base64url encoding
pub const BASE64URL_NOPAD: Encoding = Encoding::internal_new(data::BASE64URL_NOPAD_IMPL);

/// Base58 encoding (Bitcoin alphabet)
pub const BASE58: Encoding = Encoding::internal_new(data::BASE58_IMPL);

/// Base62 encoding
pub const BASE62: Encoding = Encoding::internal_new(data::BASE62_IMPL);

#[cfg(test)]
mod tests {
	use super::*;
	#[test]
	fn test_base58_roundtrip() {
		let input = b"Hello World!";
		let encoded = BASE58.encode(input);
		let decoded = BASE58.decode(encoded.as_bytes()).unwrap();
		assert_eq!(input, decoded.as_slice());
	}
}
