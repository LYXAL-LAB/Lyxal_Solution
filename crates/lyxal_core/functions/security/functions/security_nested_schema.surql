-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_nested_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_nested_schema(
    $field:string,
    $schema:object,
    $is_array:bool
)->object{
 RETURN {field:string::trim($field),schema:$schema,is_array:$is_array};
}
COMMENT "Décrit un schéma Security imbriqué."
PERMISSIONS FULL;
