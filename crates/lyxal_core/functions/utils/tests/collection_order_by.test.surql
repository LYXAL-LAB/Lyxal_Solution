-- ============================================================================
-- TESTS — fn::utils_collection_order_by
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_collection_order_by(
    [
        {group:"a",order:2},
        {group:"b",order:1},
        {group:"a",order:1}
    ],
    [
        {key:"group",direction:"asc"},
        {key:"order",direction:"asc"}
    ]
);
