-- ============================================================================
-- TESTS — fn::sanitize_remove_empty
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_remove_empty(
    {a:NONE,b:NULL,c:"",d:[],e:{},f:"ok"},
    true,
    true,
    true,
    true
);
