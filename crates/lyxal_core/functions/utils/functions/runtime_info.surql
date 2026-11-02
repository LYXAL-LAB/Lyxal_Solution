-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/runtime_info.surql
-- Fonction : fn::utils_runtime_info
--
-- Produit les informations générales d'un runtime.
--
-- Paramètres
--   $version     : object
--   $platform    : object
--   $environment : object
--   $started_at  : datetime
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
