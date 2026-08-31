-- ============================================================================
-- TESTS — fn::validation_report_merge
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_report_merge(
 {errors:[],warnings:[],fields:[]},
 {errors:[{code:"X"}],warnings:[],fields:[]},
 "MERGED"
);
