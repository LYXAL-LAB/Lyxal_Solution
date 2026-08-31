-- ============================================================================
-- TESTS — fn::security_pipeline_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_pipeline_report(
 "request",
 {findings:[{detected:true}],decisions:[]},
 [{rule:"detect_payload"}]
);
