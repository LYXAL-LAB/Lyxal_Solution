-- ============================================================================
-- TESTS — fn::security_detect_open_redirect
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_detect_open_redirect(
    "https://evil.test"
);
