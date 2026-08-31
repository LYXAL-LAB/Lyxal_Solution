-- ============================================================================
-- TESTS — fn::sanitize_currency
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_currency("1 234,56 EUR","AMOUNT",",");
