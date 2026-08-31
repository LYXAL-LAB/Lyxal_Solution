-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_cache_expired
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_cache_expired(
    $entry: object,
    $now: datetime
) -> bool {
    RETURN $entry.expires_at <= $now;
}
COMMENT "Indique si une entrée de cache est expirée."
PERMISSIONS FULL;
