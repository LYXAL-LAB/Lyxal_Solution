-- ============================================================================
-- TESTS — fn::validation_report_error_count
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_report_error_count({errors:[{code:"A"},{code:"B"}]});
