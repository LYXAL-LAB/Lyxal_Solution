-- ============================================================================
-- TESTS — fn::security_hmac_response
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hmac_response(
    200,
    d"2026-08-03T12:00:00Z",
    "abc1234567890123",
    {ok:true},
    "application/json"
);
