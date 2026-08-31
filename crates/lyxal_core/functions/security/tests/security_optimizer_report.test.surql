-- ============================================================================
-- TESTS — fn::security_optimizer_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_optimizer_report(
    [{rule:"detect_payload"},{rule:"detect_payload"}],
    [{rule:"detect_payload"}]
);
