-- ============================================================================
-- TESTS — fn::validation_report_is_valid
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_report_is_valid({errors:[]});
RETURN fn::validation_report_is_valid({errors:[{code:"X"}]});
