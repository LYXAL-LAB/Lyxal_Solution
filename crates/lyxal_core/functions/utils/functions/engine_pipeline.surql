-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_pipeline.surql
-- Fonction : fn::utils_engine_pipeline
--
-- Contrôle et normalise un pipeline : chaque étape est un objet { rule,
-- value, options } dont la règle figure au catalogue du domaine ({ rule,
-- cost, required }) ou parmi les règles du moteur (each, object, when,
-- one_of, contrôlées récursivement). Au plus $max_steps étapes par niveau.
--
-- Paramètres
--   $steps     : array
--   $catalog   : array<object>
--   $max_steps : int
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : plus de $max_steps étapes, $max_steps < 1, étape mal formée, options d'une règle du moteur invalides, règle du catalogue portant le nom d'une règle du moteur, option obligatoire (required) absente
--   CORE_UNSUPPORTED_OPTION : règle absente du catalogue
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_pipeline(
    $steps: array,
    $catalog: array<object>,
    $max_steps: int
) -> array<object> {
    IF $max_steps < 1 OR array::len($steps) > $max_steps { THROW "CORE_INVALID_ARGUMENT"; };
    LET $rules = $catalog.rule;
    IF $rules CONTAINSANY ["each", "object", "when", "one_of"] { THROW "CORE_INVALID_ARGUMENT"; };
    -- Catalogue de plus de 32 règles réduit à celles dont le nom figure dans le texte des étapes
    -- (une étape imbriquée y figure aussi) ; gardé entier si un nom n'est pas fait de [a-z0-9_]
    LET $whole = array::len($rules) <= 32 OR !string::matches(<string> $rules, "^\\[('[a-z0-9_]+'(, )?)*\\]$");
    LET $text = IF $whole { "" } ELSE { string::lowercase(<string> $steps) };
    LET $used = IF $whole { $catalog } ELSE { $catalog[WHERE string::contains($text, rule)] };
    LET $normalized = array::map($steps, |$raw| {
        IF !type::is_object($raw) OR !type::is_string($raw.rule) { THROW "CORE_INVALID_ARGUMENT"; };
        LET $step = fn::utils_engine_step($raw.rule, $raw.value, $raw.options);
        LET $rule = $step.rule;
        LET $options = $step.options;
        IF $rule = "each" {
            IF !type::is_array($options.pipeline) { THROW "CORE_INVALID_ARGUMENT"; };
            LET $pipeline = fn::utils_engine_pipeline($options.pipeline, $used, $max_steps);
            RETURN { rule: $rule, value: $step.value, options: { pipeline: $pipeline } };
        };
        IF $rule = "object" {
            IF !type::is_object($options.schema) { THROW "CORE_INVALID_ARGUMENT"; };
            LET $schema = fn::utils_engine_schema($options.schema, $used, $max_steps);
            RETURN { rule: $rule, value: $step.value, options: { schema: $schema } };
        };
        IF $rule = "when" {
            IF !type::is_array($options.then)
                OR ($options.else IS NOT NONE AND !type::is_array($options.else))
                OR ($options.field IS NOT NONE AND !type::is_string($options.field))
                OR ($options.in IS NONE AND $options.equals IS NONE)
                OR ($options.in IS NOT NONE AND !type::is_array($options.in))
            { THROW "CORE_INVALID_ARGUMENT"; };
            LET $then = fn::utils_engine_pipeline($options.then, $used, $max_steps);
            LET $else = fn::utils_engine_pipeline($options.else ?? [], $used, $max_steps);
            RETURN { rule: $rule, value: $step.value, options: object::extend($options, { then: $then, else: $else }) };
        };
        IF $rule = "one_of" {
            IF !type::is_array($options.pipelines) OR array::len($options.pipelines) < 2 { THROW "CORE_INVALID_ARGUMENT"; };
            LET $pipelines = array::map($options.pipelines, |$pipeline| {
                IF !type::is_array($pipeline) { THROW "CORE_INVALID_ARGUMENT"; };
                LET $branch = fn::utils_engine_pipeline($pipeline, $used, $max_steps);
                RETURN $branch;
            });
            RETURN { rule: $rule, value: $step.value, options: { pipelines: $pipelines } };
        };
        LET $entries = $used[WHERE rule = $rule];
        IF array::is_empty($entries) { THROW "CORE_UNSUPPORTED_OPTION"; };
        IF array::any($entries[0].required ?? [], |$key| $options[$key] IS NONE) { THROW "CORE_INVALID_ARGUMENT"; };
        RETURN $step;
    });
    RETURN $normalized;
}
COMMENT "Contrôle et normalise un pipeline : chaque étape est un objet { rule, value, options } dont la règle figure au catalogue du domaine ({ rule, cost, required }) ou parmi les règles du moteur (each, object, when, one_of, contrôlées récursivement). Au plus $max_steps étapes par niveau."
PERMISSIONS FULL;
