#![no_main]
use libfuzzer_sys::fuzz_target;
use lyxal_crypto::PasswordHash;
fuzz_target!(|data: &[u8]| {
    // Parsing/budgets only, not a full Argon2 calculation for arbitrary fuzz inputs.
    if let Ok(text) = std::str::from_utf8(data) {
        if let Ok(hash) = PasswordHash::parse(text) {
            assert_eq!(hash.expose_phc(), text);
            assert_eq!(format!("{hash:?}"), "PasswordHash([REDACTED])");
            let _ = hash.needs_rehash();
        }
    }
});
