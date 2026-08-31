-- ============================================================================
-- TESTS — fn::security_signature_request
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_signature_request(
    "POST",
    "/api/events",
    d"2026-08-03T12:00:00Z",
    "nonce123456789012",
    {"content-type":"application/json"},
    ["content-type"],
    {id:1},
    "application/json"
);
