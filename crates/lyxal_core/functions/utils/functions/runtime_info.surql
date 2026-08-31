-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_runtime_info
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_runtime_info(
    $version: object,
    $platform: object,
    $environment: object,
    $started_at: datetime
) -> object {
    RETURN {
        version:$version,
        platform:$platform,
        environment:$environment,
        started_at:$started_at,
        uptime:time::now()-$started_at,
        generated_at:time::now()
    };
}
COMMENT "Produit les informations générales d'un runtime."
PERMISSIONS FULL;
