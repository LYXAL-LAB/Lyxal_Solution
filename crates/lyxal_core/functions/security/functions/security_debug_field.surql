-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_debug_field
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_debug_field(
    $session: object,
    $field: string
) -> array<object> {
    LET $clean_field = string::trim($field);

    RETURN array::filter(
        $session.traces,
        |$trace| $trace.field = $clean_field
    );
}
COMMENT "Retourne les traces Security d'un champ."
PERMISSIONS FULL;
