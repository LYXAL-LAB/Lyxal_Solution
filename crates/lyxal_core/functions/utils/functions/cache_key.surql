-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/cache_key.surql
-- Fonction : fn::utils_cache_key
--
-- Construit une clé de cache déterministe.
--
-- Paramètres
--   $namespace : string
--   $parts     : array<any>
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $clean_namespace = ""
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_cache_key(
    $namespace: string,
    $parts: array<any>
) -> string {
    LET $clean_namespace = string::lowercase(
        string::trim($namespace)
    );

    IF $clean_namespace = "" {
        THROW "CORE_INVALID_ARGUMENT";
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
