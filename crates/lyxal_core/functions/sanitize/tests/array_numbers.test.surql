-- ============================================================================
-- TESTS — fn::sanitize_array_numbers
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_array_numbers([1,"2",3.5f,true]);
