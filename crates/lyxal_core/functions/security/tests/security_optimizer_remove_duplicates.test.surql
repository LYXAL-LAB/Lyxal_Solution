-- ============================================================================
-- TESTS — fn::security_optimizer_remove_duplicates
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_optimizer_remove_duplicates(
    [{rule:"detect_payload"},{rule:"detect_payload"}]
);
