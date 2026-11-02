-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/runtime_environment.surql
-- Fonction : fn::utils_runtime_environment
--
-- Construit les métadonnées d'environnement d'exécution.
--
-- Paramètres
--   $name     : string
--   $debug    : bool
--   $metadata : option<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : !((["development","test","staging","production"]) CONTAINS ($clean_name))
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_runtime_environment(
    $name: string,
    $debug: bool,
    $metadata: option<object>
) -> object {
    LET $clean_name = string::lowercase(string::trim($name));

    IF !((["development","test","staging","production"]) CONTAINS ($clean_name)) {
        THROW "CORE_UNSUPPORTED_OPTION";
    };

    RETURN {
        name:$clean_name,
        debug:$debug,
        metadata:IF $metadata IS NONE{{}}ELSE{$metadata}
    };
}
COMMENT "Construit les métadonnées d'environnement d'exécution."
PERMISSIONS FULL;
