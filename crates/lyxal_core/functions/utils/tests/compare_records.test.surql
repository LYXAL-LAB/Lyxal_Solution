-- ============================================================================
-- TESTS — fn::utils_compare_records
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_compare_records(
    {name:"A",status:"open",updated_at:1},
    {name:"A",status:"closed",updated_at:2},
    ["name","status"]
);
