-- ============================================================================
-- TESTS — fn::security_signature_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_signature_report(
    "ed25519",
    "key-1",
    d"2026-08-03T12:00:00Z",
    "nonce123456789012",
    true,
    NONE
);
