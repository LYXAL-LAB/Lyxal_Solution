-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_object_clone
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_object_clone(
    $value: object
) -> object {
    RETURN object::from_entries(object::entries($value));
}
COMMENT "Produit une copie superficielle d'un objet."
PERMISSIONS FULL;
