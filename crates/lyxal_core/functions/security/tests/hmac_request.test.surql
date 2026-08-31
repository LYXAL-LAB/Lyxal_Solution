-- ============================================================================
-- TESTS — fn::security_hmac_request
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hmac_request(
    "post",
    "/webhook/test",
    d"2026-08-03T12:00:00Z",
    "abc1234567890123",
    {"content-type":"application/json"},
    ["content-type"],
    {id:1},
    "application/json"
);
