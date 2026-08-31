-- ============================================================================
-- TESTS — fn::utils_object_remove_path
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::utils_object_remove_path(
    {
        user:{
            profile:{
                name:"Lyxal",
                age:1
            }
        }
    },
    ["user","profile","age"]
);
