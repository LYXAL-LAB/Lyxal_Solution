-- ============================================================================
-- TESTS — fn::security_detect_header_injection
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_detect_header_injection(
    "safe@example.com%0d%0aBcc:evil@example.com"
);
