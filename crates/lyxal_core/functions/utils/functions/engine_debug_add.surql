-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_debug_add.surql
-- Fonction : fn::utils_engine_debug_add
--
-- Ajoute une trace (fn::utils_engine_trace) à une session de débogage.
--
-- Paramètres
--   $session : object
--   $trace   : object
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_debug_add(
    $session: object,
    $trace: object
) -> object {
    RETURN object::extend($session, { traces: array::append($session.traces, $trace) });
}
COMMENT "Ajoute une trace (fn::utils_engine_trace) à une session de débogage."
PERMISSIONS FULL;
