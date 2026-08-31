-- ============================================================================
-- TESTS — fn::utils_collection_index_by
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_collection_index_by(
    [
        {id:"a",value:1},
        {id:"b",value:2}
    ],
    "id"
);
