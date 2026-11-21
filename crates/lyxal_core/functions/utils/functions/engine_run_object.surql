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
    LET $base = $state.path;
    LET $keys = object::keys($schema.fields);
    LET $states = array::map(object::entries($schema.fields), |$entry| {
        LET $key = $entry[0];
        LET $definition = $entry[1];
        LET $given = $payload[$key];
        LET $raw = IF $given IS NONE { $definition.default } ELSE { $given };
        LET $start = fn::utils_engine_state($raw, IF $base = "" { $key } ELSE { $base + "." + $key }, $payload);
        RETURN IF $raw IS NONE {
            IF $definition.required { fn::utils_engine_issue($start, "required", "CORE_VALIDATION_REQUIRED", {}) } ELSE { $start }
        } ELSE IF type::is_null($raw) {
            IF $definition.nullable { $start } ELSE { fn::utils_engine_issue($start, "nullable", "CORE_VALIDATION_NULL", {}) }
        } ELSE {
            fn::utils_engine_run($start, $definition.pipeline, $apply)
        };
    });
    LET $unknown = array::complement(object::keys($payload), $keys);
    LET $known = object::from_entries(array::transpose([$keys, $states.value])[WHERE $this[1] IS NOT NONE]);
    LET $output = IF $schema.unknown_keys = "keep" { object::extend(object::remove($payload, $keys), $known) } ELSE { $known };
    LET $unknown_issues = IF $schema.unknown_keys = "reject" {
        array::map($unknown, |$key| {
            path: IF $base = "" { $key } ELSE { $base + "." + $key },
            rule: "unknown_keys",
            code: "CORE_VALIDATION_NOT_ALLOWED",
            details: { scope: "key", key: $key }
        })
    } ELSE { [] };
    LET $field_issues = array::concat(array::flatten($states.issues), $unknown_issues);
    LET $warnings = array::flatten($states.warnings);
    LET $records = array::flatten($states.records);
    RETURN object::extend($state, {
        value: $output,
        issues: array::concat($state.issues, $field_issues),
        warnings: array::concat($state.warnings, $warnings),
        records: array::concat($state.records, $records),
        stop: array::len($field_issues) > 0
    });
}
COMMENT "Applique un schéma normalisé (fn::utils_engine_schema) à l'objet porté par l'état : valeur par défaut des champs absents, CORE_VALIDATION_REQUIRED pour un champ requis absent, CORE_VALIDATION_NULL pour un NULL non autorisé, pipeline du champ sinon ; clés inconnues rejetées (CORE_VALIDATION_NOT_ALLOWED), retirées ou conservées selon unknown_keys."
PERMISSIONS FULL;
