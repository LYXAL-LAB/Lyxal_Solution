-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_pipeline.surql
-- Fonction : fn::utils_engine_pipeline
--
-- Contrôle et normalise un pipeline : chaque étape est un objet { rule,
-- value, options } dont la règle figure au catalogue du domaine ({ rule,
-- cost }) ou parmi les règles du moteur (each, object, when, one_of,
-- contrôlées récursivement). Au plus $max_steps étapes par niveau.
--
-- Paramètres
--   $steps     : array
--   $catalog   : array<object>
--   $max_steps : int
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : plus de $max_steps étapes, $max_steps < 1, étape mal formée, options d'une règle du moteur invalides, règle du catalogue portant le nom d'une règle du moteur
--   CORE_UNSUPPORTED_OPTION : règle absente du catalogue
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_pipeline(
    $steps: array,
    $catalog: array<object>,
    $max_steps: int
) -> array<object> {
    IF $max_steps < 1 OR array::len($steps) > $max_steps { THROW "CORE_INVALID_ARGUMENT"; };
    LET $rules = array::map($catalog, |$entry| $entry.rule);
    IF array::any($rules, |$rule| $rule IN ["each", "object", "when", "one_of"]) { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN array::map($steps, |$raw| {
        IF !type::is_object($raw) OR !type::is_string($raw.rule) { THROW "CORE_INVALID_ARGUMENT"; };
        LET $step = fn::utils_engine_step($raw.rule, $raw.value, $raw.options);
        LET $options = $step.options;
        RETURN IF $step.rule = "each" {
            IF !type::is_array($options.pipeline) { THROW "CORE_INVALID_ARGUMENT"; };
            object::extend($step, { options: { pipeline: fn::utils_engine_pipeline($options.pipeline, $catalog, $max_steps) } })
        } ELSE IF $step.rule = "object" {
            IF !type::is_object($options.schema) { THROW "CORE_INVALID_ARGUMENT"; };
            object::extend($step, { options: { schema: fn::utils_engine_schema($options.schema, $catalog, $max_steps) } })
        } ELSE IF $step.rule = "when" {
            IF !type::is_array($options.then)
                OR ($options.else IS NOT NONE AND !type::is_array($options.else))
                OR ($options.field IS NOT NONE AND !type::is_string($options.field))
                OR ($options.in IS NONE AND $options.equals IS NONE)
                OR ($options.in IS NOT NONE AND !type::is_array($options.in))
            { THROW "CORE_INVALID_ARGUMENT"; };
            object::extend($step, { options: object::extend($options, {
                then: fn::utils_engine_pipeline($options.then, $catalog, $max_steps),
                else: fn::utils_engine_pipeline($options.else ?? [], $catalog, $max_steps)
            }) })
        } ELSE IF $step.rule = "one_of" {
            IF !type::is_array($options.pipelines) OR array::len($options.pipelines) < 2 { THROW "CORE_INVALID_ARGUMENT"; };
            object::extend($step, { options: { pipelines: array::map($options.pipelines, |$pipeline| {
                IF !type::is_array($pipeline) { THROW "CORE_INVALID_ARGUMENT"; };
                RETURN fn::utils_engine_pipeline($pipeline, $catalog, $max_steps);
            }) } })
        } ELSE IF $step.rule IN $rules {
            $step
        } ELSE {
            THROW "CORE_UNSUPPORTED_OPTION"
        };
    });
}
COMMENT "Contrôle et normalise un pipeline : chaque étape est un objet { rule, value, options } dont la règle figure au catalogue du domaine ({ rule, cost }) ou parmi les règles du moteur (each, object, when, one_of, contrôlées récursivement). Au plus $max_steps étapes par niveau."
PERMISSIONS FULL;
