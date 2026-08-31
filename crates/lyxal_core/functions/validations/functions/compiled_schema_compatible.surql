-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_compiled_schema_compatible
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_compiled_schema_compatible(
    $left: object,
    $right: object
) -> bool {
    LET $left_fields = object::keys($left.fields);
    LET $right_fields = object::keys($right.fields);
    RETURN array::all($left_fields, |$f| array::contains($right_fields,$f));
}
COMMENT "Vérifie une compatibilité structurelle minimale entre deux schémas compilés."
PERMISSIONS FULL;
