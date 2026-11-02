-- lyxal-test: assertions
-- Tests de fn::security_hmac_signature_header (format : crates/lyxal_core/implementation_plan.md §5).

-- test: en-tête complet
RETURN fn::security_hmac_signature_header(" HMAC-SHA256 ", " k1 ", d"2026-01-01T00:00:00Z", " n1 ", " abc ") == "algorithm=hmac-sha256,keyid=k1,timestamp=1767225600,nonce=n1,signature=abc";
