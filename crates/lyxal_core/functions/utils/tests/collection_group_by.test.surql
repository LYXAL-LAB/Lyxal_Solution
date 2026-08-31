-- ============================================================================
-- TESTS — fn::utils_collection_group_by
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_collection_group_by(
    [
        {status:"open",id:1},
        {status:"closed",id:2},
        {status:"open",id:3}
    ],
    "status"
);
