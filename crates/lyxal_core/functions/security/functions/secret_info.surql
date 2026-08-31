-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_secret_info
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_secret_info(
    $reference: string,
    $created_at: datetime,
    $rotated_at: option<datetime>,
    $status: string
) -> object {
    RETURN {
        reference: string::trim($reference),
        created_at: $created_at,
        rotated_at: $rotated_at,
        status: string::lowercase(string::trim($status)),
        contains_plaintext: false
    };
}
COMMENT "Construit les métadonnées publiques d'un secret sans sa valeur."
PERMISSIONS FULL;
