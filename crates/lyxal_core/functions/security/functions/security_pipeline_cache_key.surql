-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_pipeline_cache_key
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_pipeline_cache_key(
    $name: string,
    $version: string,
    $pipeline: array<object>
) -> string {
    RETURN string::concat(
        string::lowercase(string::trim($name)),
        "@",
        string::lowercase(string::trim($version)),
        ":",
        crypto::sha256(encoding::json::encode($pipeline))
    );
}
COMMENT "Construit une clé de cache déterministe pour un pipeline."
PERMISSIONS FULL;
