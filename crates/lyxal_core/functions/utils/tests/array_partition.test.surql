-- ============================================================================
-- TESTS — fn::utils_array_partition
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_array_partition(
    [
        {active:true,id:1},
        {active:false,id:2},
        {active:true,id:3}
    ],
    "active",
    true
);
