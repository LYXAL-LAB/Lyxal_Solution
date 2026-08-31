-- ============================================================================
-- TESTS — fn::security_optimizer_order
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_optimizer_order(
    [{rule:"redact_log"},{rule:"detect_payload"},{rule:"permission_check"}]
);
