-- ============================================================================
-- TESTS — fn::sanitize_debug_explain
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_debug_explain({field:"name",rule:"trim",changed:true,input:" A ",output:"A"});
