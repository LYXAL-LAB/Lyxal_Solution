-- ============================================================================
-- TESTS — fn::validation_report_add_error
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_report_add_error(
 {valid:true,errors:[],error_count:0,warnings:[],warning_count:0},
 {field:"email",code:"EMAIL_INVALID"}
);
