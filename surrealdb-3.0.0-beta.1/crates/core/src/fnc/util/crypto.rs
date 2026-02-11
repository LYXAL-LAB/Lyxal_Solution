use sha2::{Digest, Sha256};
use std::env;

pub fn get_scheduler_secret() -> Vec<u8> {
    env::var("SURREAL_SCHEDULER_SECRET")
        .unwrap_or_else(|_| "default_kernel_scheduler_secret_key".to_string())
        .into_bytes()
}

pub fn derive_key(secret: &[u8], salt: &[u8]) -> Vec<u8> {
    let mut hasher = Sha256::new();
    hasher.update(secret);
    hasher.update(salt);
    hasher.finalize().to_vec()
}

pub fn xor_cipher(data: &[u8], key: &[u8]) -> Vec<u8> {
    data.iter()
        .enumerate()
        .map(|(i, &byte)| byte ^ key[i % key.len()])
        .collect()
}
