-- ============================================================================
-- TESTS — fn::security_signature_response
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_signature_response(
    200,
    d"2026-08-03T12:00:00Z",
    "nonce123456789012",
    {ok:true},
    "application/json"
);
