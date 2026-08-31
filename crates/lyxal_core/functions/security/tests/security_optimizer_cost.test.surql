-- ============================================================================
-- TESTS — fn::security_optimizer_cost
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_optimizer_cost(
    [{rule:"detect_payload"},{rule:"permission_check"}]
);
