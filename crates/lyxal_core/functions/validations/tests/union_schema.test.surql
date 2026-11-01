-- ============================================================================
-- TESTS — fn::validation_union_schema
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_union_schema("42","VALUE",["string","int"]);
RETURN fn::validation_union_schema(true,"VALUE",["string","int"]);
