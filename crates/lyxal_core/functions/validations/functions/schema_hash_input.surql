-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_schema_hash_input
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_schema_hash_input(
    $source: object
) -> string {
    RETURN encoding::json::encode($source);
}
COMMENT "Produit l'entrée canonique utilisée pour calculer un hash de schéma."
PERMISSIONS FULL;
