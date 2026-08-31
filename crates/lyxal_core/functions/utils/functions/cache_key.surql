-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_cache_key
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_cache_key(
    $namespace: string,
    $parts: array<any>
) -> string {
    LET $clean_namespace = string::lowercase(
        string::trim($namespace)
    );

    IF $clean_namespace = "" {
        THROW "UTILS_INVALID_CACHE_NAMESPACE";
    };

    RETURN string::concat(
        $clean_namespace,
        ":",
        crypto::sha256(
            encoding::json::encode($parts)
        )
    );
}
COMMENT "Construit une clé de cache déterministe."
PERMISSIONS FULL;
