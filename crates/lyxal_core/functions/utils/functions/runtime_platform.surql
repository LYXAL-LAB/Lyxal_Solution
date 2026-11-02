-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/runtime_platform.surql
-- Fonction : fn::utils_runtime_platform
--
-- Construit les métadonnées de plateforme.
--
-- Paramètres
--   $engine       : string
--   $language     : string
--   $architecture : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
