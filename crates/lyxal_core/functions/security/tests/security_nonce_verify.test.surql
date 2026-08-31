-- ============================================================================
-- TESTS — fn::security_nonce_verify
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

LET $entry = fn::security_nonce_store(
    "nonce123456789012",
    "webhook:client-a",
    d"2026-08-03T12:00:00Z",
    5m
);
RETURN fn::security_nonce_verify(
    $entry,
    "nonce123456789012",
    "webhook:client-a",
    d"2026-08-03T12:01:00Z"
);
