-- ============================================================================
-- TESTS — fn::validation_warning
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_warning("password","password_weak","Mot de passe faible",NONE);
