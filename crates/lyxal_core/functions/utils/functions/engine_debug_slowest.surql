-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_debug_slowest.surql
-- Fonction : fn::utils_engine_debug_slowest
--
-- Renvoie au plus $limit traces, de la plus lente à la plus rapide.
--
-- Paramètres
--   $traces : array<object>
--   $limit  : int
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $limit < 1
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_debug_slowest(
    $traces: array<object>,
    $limit: int
) -> array<object> {
    IF $limit < 1 { THROW "CORE_INVALID_ARGUMENT"; };
    LET $ranked = array::sort::desc(array::map($traces, |$trace, $index| [duration::nanos($trace.duration), $index]));
    RETURN array::map(array::slice($ranked, 0, $limit), |$entry| $traces[$entry[1]]);
}
COMMENT "Renvoie au plus $limit traces, de la plus lente à la plus rapide."
PERMISSIONS FULL;
