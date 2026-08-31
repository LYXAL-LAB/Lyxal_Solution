-- ============================================================================
-- TESTS — fn::sanitize_optimizer_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_optimizer_report([{rule:"trim"},{rule:"trim"}],[{rule:"trim"}]);
