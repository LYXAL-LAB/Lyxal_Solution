-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_runtime_version
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_runtime_version(
    $name: string,
    $version: string,
    $contract: string
) -> object {
    RETURN {
        name:string::lowercase(string::trim($name)),
        version:string::trim($version),
        contract:string::lowercase(string::trim($contract))
    };
}
COMMENT "Construit les métadonnées de version d'un runtime."
PERMISSIONS FULL;
