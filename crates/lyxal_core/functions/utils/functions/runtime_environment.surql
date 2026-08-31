-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_runtime_environment
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_runtime_environment(
    $name: string,
    $debug: bool,
    $metadata: option<object>
) -> object {
    LET $clean_name = string::lowercase(string::trim($name));

    IF !array::contains(
        ["development","test","staging","production"],
        $clean_name
    ) {
        THROW "UTILS_INVALID_RUNTIME_ENVIRONMENT";
    };

    RETURN {
        name:$clean_name,
        debug:$debug,
        metadata:IF $metadata IS NONE{{}}ELSE{$metadata}
    };
}
COMMENT "Construit les métadonnées d'environnement d'exécution."
PERMISSIONS FULL;
