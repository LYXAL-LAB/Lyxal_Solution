-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_cache_hash
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_cache_hash(
    $entry: object
) -> string {
    RETURN crypto::sha256(
        encoding::json::encode({
            key:$entry.key,
            value:$entry.value,
            expires_at:$entry.expires_at
        })
    );
}
COMMENT "Calcule l'empreinte d'une entrée de cache."
PERMISSIONS FULL;
