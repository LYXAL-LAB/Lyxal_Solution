-- ============================================================================
-- TESTS — fn::security_optimizer_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_optimizer_schema({
    compiled_fields:{
        payload:{
            steps:[
                {rule:"detect_payload"},
                {rule:"detect_payload"}
            ]
        }
    }
});
