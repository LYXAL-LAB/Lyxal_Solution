-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_remove_unknown_keys
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_remove_unknown_keys(
    $value: object,
    $allowed_keys: array<string>
) -> object {
    RETURN object::from_entries(
        array::filter(
            object::entries($value),
            |$entry| array::contains($allowed_keys,$entry[0])
        )
    );
}
COMMENT "Supprime les clés qui ne figurent pas dans la liste autorisée."
PERMISSIONS FULL;
