-- ============================================================================
-- TESTS — fn::security_sdk_execute
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_sdk_execute(
    {
        name:"req",
        version:"v1",
        fields:{
            payload:{
                pipeline:[{rule:"detect_payload"}]
            }
        }
    },
    {payload:"<script>x</script>"},
    NONE
);
