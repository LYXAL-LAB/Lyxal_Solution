-- ============================================================================
-- TESTS — fn::security_redact_log
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_redact_log(
    "Authorization: Bearer abc.def password=secret api_key=xyz"
);
