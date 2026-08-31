-- ============================================================================
-- TESTS — fn::security_optimizer_pipeline
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_optimizer_pipeline(
    [{rule:"detect_payload"},{rule:"detect_payload"},{rule:"redact_log"}]
);
