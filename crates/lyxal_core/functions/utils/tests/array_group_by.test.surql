-- ============================================================================
-- TESTS — fn::utils_array_group_by
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_array_group_by(
    [
        {type:"a",value:1},
        {type:"b",value:2},
        {type:"a",value:3}
    ],
    "type"
);
