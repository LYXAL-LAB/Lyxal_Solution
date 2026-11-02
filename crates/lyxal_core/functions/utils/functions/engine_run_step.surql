-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_run_step.surql
-- Fonction : fn::utils_engine_run_step
--
-- Exécute une étape : les règles du moteur sont traitées ici (each : chaque
-- élément d'un tableau ; object : schéma imbriqué ; when : branche selon la
-- valeur ou le champ voisin options.field, comparé à options.equals ou
-- options.in ; one_of : première branche sans erreur, sinon
-- CORE_VALIDATION_COMBINATION) ; toute autre règle est confiée à la closure
-- $apply du domaine.
--
-- Paramètres
--   $state : object
--   $step  : object
--   $apply : function
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : règle each sur une valeur qui n'est pas un tableau, ou object sur une valeur qui n'est pas un objet (le type doit être contrôlé par une étape précédente)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_run_step(
    $state: object,
    $step: object,
    $apply: function
) -> object {
    IF $step.rule = "each" {
        IF $state.value IS NONE { RETURN $state; };
        IF !type::is_array($state.value) { THROW "CORE_INVALID_ARGUMENT"; };
        LET $items = array::map($state.value, |$item, $index|
            fn::utils_engine_run(fn::utils_engine_state($item, $state.path + "[" + <string> $index + "]", $state.parent), $step.options.pipeline, $apply)
        );
        RETURN object::extend($state, {
            value: array::map($items, |$item| $item.value),
            issues: array::concat($state.issues, array::flatten(array::map($items, |$item| $item.issues))),
            warnings: array::concat($state.warnings, array::flatten(array::map($items, |$item| $item.warnings))),
            stop: array::any($items, |$item| $item.stop)
        });
    };
    IF $step.rule = "object" {
        IF $state.value IS NONE { RETURN $state; };
        IF !type::is_object($state.value) { THROW "CORE_INVALID_ARGUMENT"; };
        RETURN fn::utils_engine_run_object($state, $step.options.schema, $apply);
    };
    IF $step.rule = "when" {
        LET $subject = IF $step.options.field IS NONE { $state.value } ELSE { $state.parent[$step.options.field] };
        LET $matched = IF $step.options.in IS NOT NONE { $subject IN $step.options.in } ELSE { $subject == $step.options.equals };
        RETURN fn::utils_engine_run($state, IF $matched { $step.options.then } ELSE { $step.options.else }, $apply);
    };
    IF $step.rule = "one_of" {
        LET $attempts = array::map($step.options.pipelines, |$pipeline|
            fn::utils_engine_run(object::extend($state, { issues: [], warnings: [], stop: false }), $pipeline, $apply)
        );
        LET $winner = array::find($attempts, |$attempt| array::len($attempt.issues) = 0);
        RETURN IF $winner IS NONE {
            fn::utils_engine_issue($state, "one_of", "CORE_VALIDATION_COMBINATION", { scope: "group", attempts: array::len($attempts) })
        } ELSE {
            object::extend($winner, { issues: $state.issues, warnings: array::concat($state.warnings, $winner.warnings) })
        };
    };
    RETURN $apply($state, $step);
}
COMMENT "Exécute une étape : les règles du moteur sont traitées ici (each : chaque élément d'un tableau ; object : schéma imbriqué ; when : branche selon la valeur ou le champ voisin options.field, comparé à options.equals ou options.in ; one_of : première branche sans erreur, sinon CORE_VALIDATION_COMBINATION) ; toute autre règle est confiée à la closure $apply du domaine."
PERMISSIONS FULL;
