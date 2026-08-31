-- ============================================================================
-- TESTS — fn::validation_debug_add_trace
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_debug_add_trace({enabled:true,traces:[]},{field:"name",rule:"trim",success:true});
