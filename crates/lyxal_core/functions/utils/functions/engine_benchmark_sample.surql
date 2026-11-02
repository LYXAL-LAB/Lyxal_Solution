-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_benchmark_sample.surql
-- Fonction : fn::utils_engine_benchmark_sample
--
-- Construit un échantillon de mesure { name, duration, ok, metadata } ; ok
-- remplace les anciens success, changed et blocked des domaines.
--
-- Paramètres
--   $name     : string
--   $duration : duration
--   $ok       : bool
--   $metadata : option<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : nom vide
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_benchmark_sample(
    $name: string,
    $duration: duration,
    $ok: bool,
    $metadata: option<object>
) -> object {
    IF string::trim($name) = "" { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN { name: string::lowercase(string::trim($name)), duration: $duration, ok: $ok, metadata: $metadata ?? {} };
}
COMMENT "Construit un échantillon de mesure { name, duration, ok, metadata } ; ok remplace les anciens success, changed et blocked des domaines."
PERMISSIONS FULL;
