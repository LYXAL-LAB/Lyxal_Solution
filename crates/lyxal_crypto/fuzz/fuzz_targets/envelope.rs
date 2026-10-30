#![no_main]
use libfuzzer_sys::fuzz_target;
use lyxal_crypto::EncryptedEnvelope;
fuzz_target!(|data: &[u8]| {
    if let Ok(text) = std::str::from_utf8(data) {
        if let Ok(parsed) = EncryptedEnvelope::parse(text) {
            assert_eq!(parsed.encode(), text);
            assert_eq!(
                EncryptedEnvelope::parse(&parsed.encode()).unwrap().encode(),
                text
            );
        }
    }
});
