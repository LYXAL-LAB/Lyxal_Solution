-- ============================================================================
-- TESTS — fn::security_detect_xss
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_detect_xss(
    "<img src=x onerror=alert(1)>"
);
