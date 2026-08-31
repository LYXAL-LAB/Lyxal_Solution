-- ============================================================================
-- TESTS — fn::security_optimizer_stats
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_optimizer_stats({
    compiled_fields:{
        payload:{steps:[{rule:"detect_payload"}]}
    }
});
