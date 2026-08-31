-- ============================================================================
-- TESTS — fn::sanitize_object_normalize
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_object_normalize(
    {name:"Lyxal",extra:true,empty:""},
    ["name","status","empty"],
    {status:"active"},
    true
);
