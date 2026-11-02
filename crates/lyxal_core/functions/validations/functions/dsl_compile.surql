-- ============================================================================
-- LYXAL OS — CORE VALIDATIONS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/dsl_compile.surql
-- Fonction : fn::validation_dsl_compile
--
-- Convertit une description DSL { name, version, fields: { <champ>: {
-- required, nullable, default, type, min_length, max_length, min, max,
-- pattern, enum } } } en schéma normalisé du moteur, utilisable par
-- fn::validation_object_execute. La normalisation (trim, casse) relève de
-- fn::sanitize_object_execute, pas du DSL.
--
-- Paramètres
--   $dsl : object
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions validations)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : name, version ou fields absents, nom de champ invalide, définition qui n'est pas un objet
--   CORE_UNSUPPORTED_OPTION : clé de définition inconnue (trim, lowercase, uppercase relèvent de sanitize)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_dsl_compile(
    $dsl: object
) -> object {
    IF !type::is_string($dsl.name) OR !type::is_string($dsl.version) OR !type::is_object($dsl.fields) { THROW "CORE_INVALID_ARGUMENT"; };
    LET $known = ["required", "nullable", "default", "type", "min_length", "max_length", "min", "max", "pattern", "enum"];
    LET $fields = object::from_entries(array::map(object::entries($dsl.fields), |$entry| {
        LET $name = $entry[0];
        LET $definition = $entry[1];
        IF !string::matches($name, "^[A-Za-z_][A-Za-z0-9_]*$") OR !type::is_object($definition) { THROW "CORE_INVALID_ARGUMENT"; };
        IF array::any(object::keys($definition), |$key| $key NOT IN $known) { THROW "CORE_UNSUPPORTED_OPTION"; };
        LET $pipeline = array::concat(
            IF $definition.type IS NONE { [] } ELSE { [{ rule: "value_type", options: { expected_type: $definition.type } }] },
            IF $definition.min_length IS NONE { [] } ELSE { [{ rule: "min_length", options: { min_length: $definition.min_length } }] },
            IF $definition.max_length IS NONE { [] } ELSE { [{ rule: "max_length", options: { max_length: $definition.max_length } }] },
            IF $definition.min IS NONE AND $definition.max IS NONE { [] } ELSE { [{ rule: "number", options: { min_value: $definition.min, max_value: $definition.max } }] },
            IF $definition.pattern IS NONE { [] } ELSE { [{ rule: "regex", options: { pattern: $definition.pattern } }] },
            IF $definition.enum IS NONE { [] } ELSE { [{ rule: "enum_any", options: { allowed_values: $definition.enum } }] }
        );
        RETURN [$name, { pipeline: $pipeline, required: $definition.required, nullable: $definition.nullable, default: $definition.default }];
    }));
    RETURN fn::utils_engine_schema({ name: $dsl.name, version: $dsl.version, fields: $fields }, fn::validation_step_catalog(), 10);
}
COMMENT "Convertit une description DSL { name, version, fields: { <champ>: { required, nullable, default, type, min_length, max_length, min, max, pattern, enum } } } en schéma normalisé du moteur, utilisable par fn::validation_object_execute. La normalisation (trim, casse) relève de fn::sanitize_object_execute, pas du DSL."
PERMISSIONS FULL;
