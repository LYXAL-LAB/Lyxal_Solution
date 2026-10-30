#![no_main]
use libfuzzer_sys::fuzz_target;
use lyxal_crypto::SecretContext;
fuzz_target!(|data: &[u8]| {
    if let Ok(text) = std::str::from_utf8(data) {
        let _ = SecretContext::global(text);
        let mut pieces = text.splitn(5, '\0');
        if let (Some(a), Some(b), Some(c), Some(d), Some(e)) = (
            pieces.next(),
            pieces.next(),
            pieces.next(),
            pieces.next(),
            pieces.next(),
        ) {
            if let Ok(ctx) = SecretContext::with_tenant(a, b, c, d, e) {
                assert_eq!(ctx, SecretContext::with_tenant(a, b, c, d, e).unwrap());
                assert_eq!(format!("{ctx:?}"), "SecretContext([REDACTED])");
            }
        }
    }
});
