-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_runtime_platform
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_runtime_platform(
    $engine: string,
    $language: string,
    $architecture: string
) -> object {
    RETURN {
        engine:string::lowercase(string::trim($engine)),
        language:string::lowercase(string::trim($language)),
        architecture:string::lowercase(string::trim($architecture))
    };
}
COMMENT "Construit les métadonnées de plateforme."
PERMISSIONS FULL;
