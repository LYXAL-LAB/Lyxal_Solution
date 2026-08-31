-- ============================================================================
-- TESTS — fn::validation_nested_array
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_nested_array(
 [{name:"A"},{name:"B"}],
 "ITEMS",
 {name:{required:true,type:"string"}},
 1,
 10
);
