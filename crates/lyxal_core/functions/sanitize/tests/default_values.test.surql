-- ============================================================================
-- TESTS — fn::sanitize_default_values
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_default_values(
    {name:"Lyxal"},
    {name:"Default",status:"active"}
);
