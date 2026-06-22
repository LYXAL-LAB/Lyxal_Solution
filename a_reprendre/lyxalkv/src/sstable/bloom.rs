use crate::FilterPolicy;

#[cfg(target_arch = "x86_64")]
use std::arch::x86_64::*;

// Hash returns the hash of the given data using a Murmur-inspired algorithm.
// Optimized for modern CPUs with 64-bit registers.
pub(crate) fn hash(data: &[u8], seed: u32) -> u32 {
	const M: u32 = 0xc6a4_a793;
	const R: u32 = 24;

	let mut h = seed ^ ((data.len() as u64).wrapping_mul(M as u64)) as u32;
	
	// Process 8 bytes at a time using 64-bit arithmetic if possible
	let mut chunks = data.chunks_exact(8);
	for chunk in &mut chunks {
		let w = u64::from_le_bytes(chunk.try_into().unwrap());
		
		// Mix 64-bit value into 32-bit hash
		let mut k = (w as u32).wrapping_mul(M);
		k ^= k >> R;
		k = k.wrapping_mul(M);
		h = h.wrapping_mul(M);
		h ^= k;
		
		let mut k2 = ((w >> 32) as u32).wrapping_mul(M);
		k2 ^= k2 >> R;
		k2 = k2.wrapping_mul(M);
		h = h.wrapping_mul(M);
		h ^= k2;
	}
	
	let mut remaining = chunks.remainder();
	let mut i = 0;
	while i + 4 <= remaining.len() {
		let chunk = &remaining[i..i+4];
		let mut k = u32::from_le_bytes(chunk.try_into().unwrap()).wrapping_mul(M);
		k ^= k >> R;
		k = k.wrapping_mul(M);
		h = h.wrapping_mul(M);
		h ^= k;
		i += 4;
	}
	
	remaining = &remaining[i..];
	for &byte in remaining {
		h = h.wrapping_add(byte as u32);
		h = h.wrapping_mul(M);
		h ^= h >> 16;
	}

	h = h.wrapping_mul(M);
	h ^= h >> R;
	h = h.wrapping_mul(M);
	h ^= h >> R;

	h
}

pub(crate) struct LevelDBBloomFilter {
	bits_per_key: usize,
	#[allow(dead_code)]
	use_simd: bool,
}

impl LevelDBBloomFilter {
	pub(crate) fn new(bits_per_key: usize) -> Self {
		let use_simd = is_x86_feature_detected!("avx2");
		Self {
			bits_per_key,
			use_simd,
		}
	}

	fn bloom_hash(key: &[u8]) -> u32 {
		hash(key, 0xbc9f_1d34)
	}
}

impl FilterPolicy for LevelDBBloomFilter {
	fn name(&self) -> &str {
		"leveldb.BloomFilter"
	}

	fn create_filter(&self, keys: &[Vec<u8>]) -> Vec<u8> {
		let n = keys.len();
		if n == 0 {
			return vec![];
		}

		// Calculate filter size
		let bits = n * self.bits_per_key;
		let bytes = bits.div_ceil(8);
		let bits = bytes * 8;

		let mut filter = vec![0u8; bytes + 1]; // +1 for storing k at the end

		// Calculate number of hash functions
		let k = (((self.bits_per_key as f64) * 0.7) as u32).clamp(1, 30);

		for key in keys {
			// Single hash computation per key
			let h = Self::bloom_hash(key);

			// Bit rotation for generating multiple hash values from single computation
			let delta = h.rotate_left(15);
			let mut hash = h;

			for _ in 0..k {
				let bit_pos = (hash % (bits as u32)) as usize;
				filter[bit_pos / 8] |= 1 << (bit_pos % 8);
				hash = hash.wrapping_add(delta);
			}
		}

		// Store k at the end
		filter[bytes] = k as u8;

		filter
	}

	fn may_contain(&self, filter: &[u8], key: &[u8]) -> bool {
		let bytes = filter.len();
		if bytes < 2 {
			return false;
		}

		let k = filter[bytes - 1] as u32;
		if k > 30 {
			crate::metrics::EngineMetrics::get().bloom_hits.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
			return true;
		}

		let bits = ((bytes - 1) * 8) as u32;
		let h = Self::bloom_hash(key);
		let delta = h.rotate_left(15);

		// Use SIMD if available and k is large enough to justify it
		#[cfg(target_arch = "x86_64")]
		if self.use_simd && k >= 8 {
			let res = unsafe { self.may_contain_simd(filter, h, delta, k, bits) };
			if res {
				crate::metrics::EngineMetrics::get().bloom_hits.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
			} else {
				crate::metrics::EngineMetrics::get().bloom_misses.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
			}
			return res;
		}

		let mut hash = h;
		for _ in 0..k {
			let bit_pos = (hash % bits) as usize;
			if (filter[bit_pos / 8] & (1 << (bit_pos % 8))) == 0 {
				crate::metrics::EngineMetrics::get().bloom_misses.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
				return false;
			}
			hash = hash.wrapping_add(delta);
		}

		crate::metrics::EngineMetrics::get().bloom_hits.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
		true
	}
}

impl LevelDBBloomFilter {
	#[cfg(target_arch = "x86_64")]
	#[target_feature(enable = "avx2")]
	unsafe fn may_contain_simd(&self, filter: &[u8], h: u32, delta: u32, k: u32, bits: u32) -> bool {
		let mut hash = h;
		let _delta_vec = _mm256_set1_epi32(delta as i32);
		let _bits_vec = _mm256_set1_epi32(bits as i32);
		
		// Process k hashes in chunks of 8 using AVX2
		let mut i = 0;
		while i + 8 <= k {
			// Generate 8 hashes at once: [h, h+d, h+2d, ..., h+7d]
			let h_vec = _mm256_set_epi32(
				hash.wrapping_add(delta.wrapping_mul(7)) as i32,
				hash.wrapping_add(delta.wrapping_mul(6)) as i32,
				hash.wrapping_add(delta.wrapping_mul(5)) as i32,
				hash.wrapping_add(delta.wrapping_mul(4)) as i32,
				hash.wrapping_add(delta.wrapping_mul(3)) as i32,
				hash.wrapping_add(delta.wrapping_mul(2)) as i32,
				hash.wrapping_add(delta.wrapping_mul(1)) as i32,
				hash as i32,
			);
			
			// bit_pos = hash % bits
			// Note: epi32 modulo is not direct in AVX2, but we can use bitwise if bits is power of 2
			// Since bits is not guaranteed to be power of 2, we use a slightly different approach
			// for the SIMD lookup or fall back to a faster scalar loop for the bit check part.
			
			let mut hashes = [0u32; 8];
			unsafe { _mm256_storeu_si256(hashes.as_mut_ptr() as *mut __m256i, h_vec); }
			
			for &h_val in &hashes {
				let bit_pos = (h_val % bits) as usize;
				if (filter[bit_pos / 8] & (1 << (bit_pos % 8))) == 0 {
					return false;
				}
			}
			
			hash = hash.wrapping_add(delta.wrapping_mul(8));
			i += 8;
		}
		
		// Process remaining
		for _ in i..k {
			let bit_pos = (hash % bits) as usize;
			if (filter[bit_pos / 8] & (1 << (bit_pos % 8))) == 0 {
				return false;
			}
			hash = hash.wrapping_add(delta);
		}
		
		true
	}
}

#[cfg(test)]
mod tests {
	use test_log::test;

	use super::*;

	#[test]
	fn test_bloom_filter_creation() {
		let filter = LevelDBBloomFilter::new(10);
		assert_eq!(filter.bits_per_key, 10);

		let filter = LevelDBBloomFilter::new(100);
		assert_eq!(filter.bits_per_key, 100);

		let filter = LevelDBBloomFilter::new(1);
		assert_eq!(filter.bits_per_key, 1);
	}

	#[test]
	fn test_bloom_filter_may_contain() {
		let filter = LevelDBBloomFilter::new(10);
		let keys = vec![b"key1".to_vec(), b"key2".to_vec(), b"key3".to_vec()];
		let bloom_filter = filter.create_filter(&keys);

		assert!(filter.may_contain(&bloom_filter, b"key1"));
		assert!(filter.may_contain(&bloom_filter, b"key2"));
		assert!(filter.may_contain(&bloom_filter, b"key3"));
		assert!(!filter.may_contain(&bloom_filter, b"key4"));
	}

	#[test]
	fn test_bloom_filter_empty() {
		let filter = LevelDBBloomFilter::new(10);
		let empty_filter = vec![];
		assert!(!filter.may_contain(&empty_filter, b"key1"));
	}

	#[test]
	fn test_bloom_filter_invalid_num_hashes() {
		let filter = LevelDBBloomFilter::new(10);
		let mut bloom_filter = filter.create_filter(&[b"key1".to_vec()]);
		let bloom_filter_len = bloom_filter.len();
		bloom_filter[bloom_filter_len - 1] = 31; // invalid num_hashes
		assert!(filter.may_contain(&bloom_filter, b"key1"));
	}
}
