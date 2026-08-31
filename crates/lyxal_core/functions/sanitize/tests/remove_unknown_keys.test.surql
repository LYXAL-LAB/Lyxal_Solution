-- ============================================================================
-- TESTS — fn::sanitize_remove_unknown_keys
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_remove_unknown_keys(
    {name:"Lyxal",extra:true},
    ["name"]
);
