-- ============================================================================
-- TESTS — fn::security_hmac_payload
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_hmac_payload(
    {event:"created",id:1},
    "application/json"
);
