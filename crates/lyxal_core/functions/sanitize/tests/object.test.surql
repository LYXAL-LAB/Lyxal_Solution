-- ============================================================================
-- TESTS — fn::sanitize_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_object(NONE);
RETURN fn::sanitize_object({name:"Lyxal"});
