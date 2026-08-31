-- ============================================================================
-- TESTS — fn::sanitize_percentage
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_percentage("12,5 %","PERCENT");
