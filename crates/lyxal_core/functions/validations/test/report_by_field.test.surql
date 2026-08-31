-- ============================================================================
-- TESTS — fn::validation_report_by_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_report_by_field(
 {errors:[{field:"email",code:"EMAIL_INVALID"}],warnings:[]},
 "email"
);
