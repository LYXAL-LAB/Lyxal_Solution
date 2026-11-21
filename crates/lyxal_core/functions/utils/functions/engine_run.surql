-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_run.surql
-- Fonction : fn::utils_engine_run
--
-- Exécute un pipeline normalisé sur un état : chaque étape est confiée à
-- fn::utils_engine_run_step (une règle du domaine directement à la closure
-- $apply) ; l'exécution s'arrête dès qu'une étape positionne stop.
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
    -- Une règle du domaine va droit à $apply, comme le ferait fn::utils_engine_run_step
    RETURN array::fold($pipeline, $state, |$current, $step|
        IF $current.stop { $current }
        ELSE IF $step.rule IN ["each", "object", "when", "one_of"] { fn::utils_engine_run_step($current, $step, $apply) }
        ELSE { $apply($current, $step) }
    );
}
COMMENT "Exécute un pipeline normalisé sur un état : chaque étape est confiée à fn::utils_engine_run_step (une règle du domaine directement à la closure $apply) ; l'exécution s'arrête dès qu'une étape positionne stop."
PERMISSIONS FULL;
