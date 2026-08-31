-- ============================================================================
-- TESTS — fn::sanitize_e164
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_e164("06 12 34 56 78","PHONE","33");
