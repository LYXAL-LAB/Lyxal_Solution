-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/runtime_version.surql
-- Fonction : fn::utils_runtime_version
--
-- Construit les métadonnées de version d'un runtime.
--
-- Paramètres
--   $name     : string
--   $version  : string
--   $contract : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
