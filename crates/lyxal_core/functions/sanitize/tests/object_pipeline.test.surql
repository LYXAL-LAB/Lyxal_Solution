-- ============================================================================
-- TESTS — fn::sanitize_object_pipeline
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_object_pipeline(
    {name:"Lyxal",extra:true,empty:""},
    [
        {rule:"keep_keys",value:["name","status","empty"]},
        {rule:"defaults",value:{status:"active"}},
        {rule:"remove_empty"}
    ]
);
