-- ============================================================================
-- TESTS — fn::utils_object_pick
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_object_pick(
    {name:"Lyxal",version:1,active:true},
    ["name","active"]
);
