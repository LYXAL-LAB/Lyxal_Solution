-- ============================================================================
-- TESTS — fn::security_optimizer_validate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_optimizer_validate(
    [{rule:"detect_payload"},{rule:"redact_log"}]
);
