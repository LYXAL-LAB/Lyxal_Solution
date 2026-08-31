-- ============================================================================
-- TESTS — fn::security_detect_sql_injection
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_detect_sql_injection(
    "' OR 1=1 --"
);
