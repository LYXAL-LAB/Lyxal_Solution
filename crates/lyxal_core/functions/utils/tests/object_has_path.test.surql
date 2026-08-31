-- ============================================================================
-- TESTS — fn::utils_object_has_path
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_object_has_path(
    {
        user:{
            profile:{
                name:"Lyxal"
            }
        }
    },
    ["user","profile","name"]
);
