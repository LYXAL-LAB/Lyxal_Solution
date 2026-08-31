-- ============================================================================
-- TESTS — fn::sanitize_array
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_array("Lyxal");
RETURN fn::sanitize_array(["A","B"]);
