-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_field(
    $name: string,
    $pipeline: array<object>,
    $default_value: option<any>,
    $nullable: bool
) -> object {
    LET $clean_name = string::trim($name);
    IF !string::matches($clean_name,"^[A-Za-z_][A-Za-z0-9_]*$") {
        THROW "SANITIZE_INVALID_FIELD_NAME";
    };
    RETURN {
        name: $clean_name,
        pipeline: $pipeline,
        default: $default_value,
        nullable: $nullable
    };
}
COMMENT "Construit une définition de champ de sanitation."
PERMISSIONS FULL;
