-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_run.surql
-- Fonction : fn::utils_engine_run
--
-- Exécute un pipeline normalisé sur un état : chaque étape est confiée à
-- fn::utils_engine_run_step ; l'exécution s'arrête dès qu'une étape
-- positionne stop.
--
-- Paramètres
--   $state    : object
--   $pipeline : array<object>
--   $apply    : function
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_run(
    $state: object,
    $pipeline: array<object>,
    $apply: function
) -> object {
    RETURN array::fold($pipeline, $state, |$current, $step|
        IF $current.stop { $current } ELSE { fn::utils_engine_run_step($current, $step, $apply) }
    );
}
COMMENT "Exécute un pipeline normalisé sur un état : chaque étape est confiée à fn::utils_engine_run_step ; l'exécution s'arrête dès qu'une étape positionne stop."
PERMISSIONS FULL;
