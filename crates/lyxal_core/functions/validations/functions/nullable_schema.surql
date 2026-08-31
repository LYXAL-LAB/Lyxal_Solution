-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_nullable_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_nullable_schema(
    $schema: object,
    $nullable: bool
) -> object {
    RETURN object::extend($schema, {nullable:$nullable});
}
COMMENT "Ajoute ou remplace la politique nullable d'un schéma."
PERMISSIONS FULL;
