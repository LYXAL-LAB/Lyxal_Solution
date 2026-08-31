-- ============================================================================
-- TESTS — fn::validation_nested_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_nested_object(
 {city:"Paris"},
 "ADDRESS",
 {city:{required:true,type:"string"}},
 false
);
