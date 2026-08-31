-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_array_objects
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array_objects(
    $value: array<any>
) -> array<object> {
    RETURN array::filter(
        $value,
        |$item| type::is_object($item)
    );
}
COMMENT "Conserve uniquement les objets d'un tableau."
PERMISSIONS FULL;
