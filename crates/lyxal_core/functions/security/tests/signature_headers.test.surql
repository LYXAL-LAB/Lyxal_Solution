-- ============================================================================
-- TESTS — fn::security_signature_headers
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_signature_headers(
    {"content-type":"application/json","x-id":"1"},
    ["x-id","content-type"]
);
