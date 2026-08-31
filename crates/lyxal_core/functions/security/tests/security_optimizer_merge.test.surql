-- ============================================================================
-- TESTS — fn::security_optimizer_merge
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_optimizer_merge(
    [{rule:"detect_payload"}],
    [{rule:"detect_payload"},{rule:"redact_log"}]
);
