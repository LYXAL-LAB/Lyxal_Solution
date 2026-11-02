-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_debug_session.surql
-- Fonction : fn::utils_engine_debug_session
--
-- Ouvre une session de débogage { name, started_at, traces } ; les traces
-- s'ajoutent avec fn::utils_engine_debug_add.
--
-- Paramètres
--   $name       : string
--   $started_at : datetime
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : nom vide
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_debug_session(
    $name: string,
    $started_at: datetime
) -> object {
    IF string::trim($name) = "" { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN { name: string::trim($name), started_at: $started_at, traces: [] };
}
COMMENT "Ouvre une session de débogage { name, started_at, traces } ; les traces s'ajoutent avec fn::utils_engine_debug_add."
PERMISSIONS FULL;
