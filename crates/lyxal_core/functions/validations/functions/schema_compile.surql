-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_compile
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_compile(
    $name: string,
    $version: string,
    $definition: object
) -> object {
    LET $source = fn::validation_schema_source($name,$version,$definition);
    LET $fields = fn::validation_compile_object_schema($definition);
    RETURN fn::validation_compiled_schema($source,$fields);
}
COMMENT "Compile un schéma déclaratif complet."
PERMISSIONS FULL;
