-- ============================================================================
-- TESTS — fn::security_nested_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_nested_schema("items",{name:"item",version:"v1"},true);
