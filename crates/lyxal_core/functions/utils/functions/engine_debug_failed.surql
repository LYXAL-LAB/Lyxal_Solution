-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_debug_failed.surql
-- Fonction : fn::utils_engine_debug_failed
--
-- Renvoie les traces en échec (ok = false), dans leur ordre d'origine.
--
-- Paramètres
--   $traces : array<object>
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_debug_failed(
    $traces: array<object>
) -> array<object> {
    RETURN array::filter($traces, |$trace| !$trace.ok);
}
COMMENT "Renvoie les traces en échec (ok = false), dans leur ordre d'origine."
PERMISSIONS FULL;
