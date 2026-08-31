-- ============================================================================
-- TESTS — fn::utils_object_get_path
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_object_get_path(
    {
        user:{
            profile:{
                name:"Lyxal"
            }
        }
    },
    ["user","profile","name"],
    "inconnu"
);
