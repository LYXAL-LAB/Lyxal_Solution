-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_run_step.surql
-- Fonction : fn::utils_engine_run_step
--
-- Exécute une étape : les règles du moteur sont traitées ici (each : chaque
-- élément d'un tableau ; object : schéma imbriqué ; when : branche selon la
-- valeur ou le champ voisin options.field, comparé à options.equals ou
-- options.in ; one_of : branches essayées dans l'ordre, arrêt à la première
-- sans erreur, sinon CORE_VALIDATION_COMBINATION) ; toute autre règle est
-- confiée à la closure $apply du domaine.
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
    LET $rule = $step.rule;
    IF $rule = "each" {
        LET $items = $state.value;
        IF $items IS NONE { RETURN $state; };
        IF !type::is_array($items) { THROW "CORE_INVALID_ARGUMENT"; };
        LET $path = $state.path;
        LET $siblings = $state.parent;
        LET $pipeline = $step.options.pipeline;
        LET $outcomes = array::map($items, |$item, $index| {
            LET $start = fn::utils_engine_state($item, $path + "[" + <string> $index + "]", $siblings);
            RETURN fn::utils_engine_run($start, $pipeline, $apply);
        });
        LET $issues = array::flatten($outcomes.issues);
        LET $warnings = array::flatten($outcomes.warnings);
        LET $records = array::flatten($outcomes.records);
        RETURN object::extend($state, {
            value: $outcomes.value,
            issues: array::concat($state.issues, $issues),
            warnings: array::concat($state.warnings, $warnings),
            records: array::concat($state.records, $records),
            stop: array::any($outcomes.stop)
        });
    };
    IF $rule = "object" {
        IF $state.value IS NONE { RETURN $state; };
        IF !type::is_object($state.value) { THROW "CORE_INVALID_ARGUMENT"; };
        LET $outcome = fn::utils_engine_run_object($state, $step.options.schema, $apply);
        RETURN $outcome;
    };
    IF $rule = "when" {
        LET $subject = IF $step.options.field IS NONE { $state.value } ELSE { $state.parent[$step.options.field] };
        LET $matched = IF $step.options.in IS NOT NONE { $subject IN $step.options.in } ELSE { $subject == $step.options.equals };
        LET $outcome = fn::utils_engine_run($state, IF $matched { $step.options.then } ELSE { $step.options.else }, $apply);
        RETURN $outcome;
    };
    IF $rule = "one_of" {
        LET $outcome = array::fold($step.options.pipelines, { winner: NONE, attempts: 0 }, |$acc, $pipeline| {
            IF $acc.winner IS NOT NONE { RETURN $acc; };
            LET $attempt = fn::utils_engine_run(object::extend($state, { issues: [], warnings: [], records: [], stop: false }), $pipeline, $apply);
            RETURN { winner: IF array::len($attempt.issues) = 0 { $attempt } ELSE { NONE }, attempts: $acc.attempts + 1 };
        });
        RETURN IF $outcome.winner IS NONE {
            fn::utils_engine_issue($state, "one_of", "CORE_VALIDATION_COMBINATION", { scope: "group", attempts: $outcome.attempts })
        } ELSE {
            object::extend($outcome.winner, { issues: $state.issues, warnings: array::concat($state.warnings, $outcome.winner.warnings), records: array::concat($state.records, $outcome.winner.records) })
        };
    };
    LET $outcome = $apply($state, $step);
    RETURN $outcome;
}
COMMENT "Exécute une étape : les règles du moteur sont traitées ici (each : chaque élément d'un tableau ; object : schéma imbriqué ; when : branche selon la valeur ou le champ voisin options.field, comparé à options.equals ou options.in ; one_of : branches essayées dans l'ordre, arrêt à la première sans erreur, sinon CORE_VALIDATION_COMBINATION) ; toute autre règle est confiée à la closure $apply du domaine."
PERMISSIONS FULL;
