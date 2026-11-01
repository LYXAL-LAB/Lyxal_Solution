-- ============================================================================
-- TESTS — fn::validation_error
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_error("email","email_invalid","Adresse invalide",NONE);
RETURN fn::validation_error("email","   ",NONE,NONE);
