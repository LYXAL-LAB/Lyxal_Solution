-- ============================================================================
-- TESTS — fn::validation_report_add_warning
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_report_add_warning(
 {valid:true,errors:[],error_count:0,warnings:[],warning_count:0},
 {field:"password",code:"PASSWORD_WEAK"}
);
