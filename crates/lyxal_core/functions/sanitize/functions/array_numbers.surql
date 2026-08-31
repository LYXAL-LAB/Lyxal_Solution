-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_array_numbers
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_numbers(
    $value: array<any>
) -> array<number> {
    RETURN array::filter(
        $value,
        |$item| type::is_number($item)
    );
}
COMMENT "Conserve uniquement les nombres d'un tableau."
PERMISSIONS FULL;
