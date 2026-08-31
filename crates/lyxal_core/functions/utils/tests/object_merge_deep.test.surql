-- ============================================================================
-- TESTS — fn::utils_object_merge_deep
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_object_merge_deep(
    {
        config:{
            enabled:true,
            retries:3
        }
    },
    {
        config:{
            retries:5
        }
    }
);
