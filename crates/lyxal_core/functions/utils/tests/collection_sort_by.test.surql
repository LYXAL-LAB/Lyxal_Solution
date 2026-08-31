-- ============================================================================
-- TESTS — fn::utils_collection_sort_by
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_collection_sort_by(
    [
        {name:"B",order:2},
        {name:"A",order:1}
    ],
    "order",
    "asc"
);
