-- ============================================================================
-- TESTS — fn::security_signature_payload
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_signature_payload(
    {id:1,event:"created"},
    "application/json"
);
