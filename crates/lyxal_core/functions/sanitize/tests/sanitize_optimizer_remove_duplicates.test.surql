-- ============================================================================
-- TESTS — fn::sanitize_optimizer_remove_duplicates
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_optimizer_remove_duplicates([{rule:"trim"},{rule:"trim"}]);
