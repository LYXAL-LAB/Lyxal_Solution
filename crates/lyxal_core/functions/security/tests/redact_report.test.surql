-- ============================================================================
-- TESTS — fn::security_redact_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_redact_report(
    "user",
    {password:"secret"},
    {password:"***REDACTED***"},
    ["password"]
);
