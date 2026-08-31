-- ============================================================================
-- TESTS — fn::utils_object_set_path
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_object_set_path(
    {user:{}},
    ["user","profile","name"],
    "Lyxal"
);
