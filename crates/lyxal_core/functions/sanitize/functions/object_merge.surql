-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_object_merge
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_object_merge(
    $base: object,
    $override: object
) -> object {
    RETURN object::extend($base,$override);
}
COMMENT "Fusionne deux objets avec priorité au second."
PERMISSIONS FULL;
