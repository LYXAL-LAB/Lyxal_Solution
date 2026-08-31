-- ============================================================================
-- TESTS — fn::sanitize_keep_keys
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_keep_keys(
    {name:"Lyxal",age:1},
    ["name"]
);
