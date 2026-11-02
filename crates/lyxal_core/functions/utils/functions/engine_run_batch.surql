-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_run_batch.surql
-- Fonction : fn::utils_engine_run_batch
--
-- Exécute un même pipeline sur chaque valeur d'un tableau ; renvoie un état
-- par valeur.
--
-- Paramètres
--   $values   : array
--   $pipeline : array<object>
--   $apply    : function
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_run_batch(
    $values: array,
    $pipeline: array<object>,
    $apply: function
) -> array<object> {
    RETURN array::map($values, |$value| fn::utils_engine_run(fn::utils_engine_state($value, "", NONE), $pipeline, $apply));
}
COMMENT "Exécute un même pipeline sur chaque valeur d'un tableau ; renvoie un état par valeur."
PERMISSIONS FULL;
