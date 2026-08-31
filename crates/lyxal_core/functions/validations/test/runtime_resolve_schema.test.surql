-- ============================================================================
-- TESTS — fn::validation_runtime_resolve_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_runtime_resolve_schema([{name:"user",version:"v1",status:"active",schema:{}}],"user","v1");
