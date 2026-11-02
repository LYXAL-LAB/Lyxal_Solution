-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_run_object.surql
-- Fonction : fn::utils_engine_run_object
--
-- Applique un schéma normalisé (fn::utils_engine_schema) à l'objet porté par
-- l'état : valeur par défaut des champs absents, CORE_VALIDATION_REQUIRED
-- pour un champ requis absent, CORE_VALIDATION_NULL pour un NULL non
-- autorisé, pipeline du champ sinon ; clés inconnues rejetées
-- (CORE_VALIDATION_NOT_ALLOWED), retirées ou conservées selon unknown_keys.
--
-- Paramètres
--   $state  : object
--   $schema : object
--   $apply  : function
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_run_object(
    $state: object,
    $schema: object,
    $apply: function
) -> object {
    LET $payload = $state.value;
    LET $keys = object::keys($schema.fields);
    LET $results = array::map($keys, |$key| {
        LET $definition = $schema.fields[$key];
        LET $raw = IF $payload[$key] IS NONE { $definition.default } ELSE { $payload[$key] };
        LET $start = fn::utils_engine_state($raw, IF $state.path = "" { $key } ELSE { $state.path + "." + $key }, $payload);
        RETURN [$key, IF $raw IS NONE {
            IF $definition.required { fn::utils_engine_issue($start, "required", "CORE_VALIDATION_REQUIRED", {}) } ELSE { $start }
        } ELSE IF type::is_null($raw) {
            IF $definition.nullable { $start } ELSE { fn::utils_engine_issue($start, "nullable", "CORE_VALIDATION_NULL", {}) }
        } ELSE {
            fn::utils_engine_run($start, $definition.pipeline, $apply)
        }];
    });
    LET $unknown = array::filter(object::keys($payload), |$key| $key NOT IN $keys);
    LET $known = object::from_entries(array::filter(array::map($results, |$result| [$result[0], $result[1].value]), |$entry| $entry[1] IS NOT NONE));
    LET $output = IF $schema.unknown_keys = "keep" {
        object::extend(object::from_entries(array::map($unknown, |$key| [$key, $payload[$key]])), $known)
    } ELSE { $known };
    LET $unknown_issues = IF $schema.unknown_keys = "reject" {
        array::map($unknown, |$key| {
            path: IF $state.path = "" { $key } ELSE { $state.path + "." + $key },
            rule: "unknown_keys",
            code: "CORE_VALIDATION_NOT_ALLOWED",
            details: { scope: "key", key: $key }
        })
    } ELSE { [] };
    LET $field_issues = array::concat(array::flatten(array::map($results, |$result| $result[1].issues)), $unknown_issues);
    RETURN object::extend($state, {
        value: $output,
        issues: array::concat($state.issues, $field_issues),
        warnings: array::concat($state.warnings, array::flatten(array::map($results, |$result| $result[1].warnings))),
        stop: array::len($field_issues) > 0
    });
}
COMMENT "Applique un schéma normalisé (fn::utils_engine_schema) à l'objet porté par l'état : valeur par défaut des champs absents, CORE_VALIDATION_REQUIRED pour un champ requis absent, CORE_VALIDATION_NULL pour un NULL non autorisé, pipeline du champ sinon ; clés inconnues rejetées (CORE_VALIDATION_NOT_ALLOWED), retirées ou conservées selon unknown_keys."
PERMISSIONS FULL;
