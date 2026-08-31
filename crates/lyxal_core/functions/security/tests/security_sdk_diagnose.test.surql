-- ============================================================================
-- TESTS — fn::security_sdk_diagnose
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_sdk_diagnose({
    name:"req",
    version:"v1",
    fields:{
        payload:{
            pipeline:[
                {rule:"detect_payload"},
                {rule:"detect_payload"}
            ]
        }
    }
});
