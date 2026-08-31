-- ============================================================================
-- TESTS — fn::security_detect_payload
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_detect_payload(
    "<script>alert(1)</script>"
);
