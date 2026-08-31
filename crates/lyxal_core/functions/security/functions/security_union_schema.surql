-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_union_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_union_schema(
    $schemas:array<object>,
    $discriminator:option<string>
)->object{
 IF array::len($schemas)<2{THROW "SECURITY_UNION_REQUIRES_MULTIPLE_SCHEMAS";};
 RETURN {schemas:$schemas,discriminator:$discriminator};
}
COMMENT "Construit une union de schémas Security."
PERMISSIONS FULL;
