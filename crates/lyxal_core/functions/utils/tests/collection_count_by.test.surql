-- ============================================================================
-- TESTS — fn::utils_collection_count_by
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_collection_count_by(
    [
        {status:"open"},
        {status:"closed"},
        {status:"open"}
    ],
    "status"
);
