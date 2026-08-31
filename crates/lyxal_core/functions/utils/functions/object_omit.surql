-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_object_omit
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_object_omit(
    $value: object,
    $keys: array<string>
) -> object {
    RETURN object::from_entries(
        array::filter(
            object::entries($value),
            |$entry| !array::contains($keys,$entry[0])
        )
    );
}
COMMENT "Retire les clés demandées d'un objet."
PERMISSIONS FULL;
