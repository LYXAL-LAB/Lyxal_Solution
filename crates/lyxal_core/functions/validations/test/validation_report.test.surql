-- ============================================================================
-- TESTS — fn::validation_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_report("USER",[
 {field:"name",valid:true,value:"Lyxal",errors:[],warnings:[]}
]);
