-- ============================================================================
-- TESTS — fn::validation_schema_registry_entry
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_schema_registry_entry(
 "user::profile",1,{name:{type:"string"}},"active"
);
