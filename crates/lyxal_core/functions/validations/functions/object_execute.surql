-- ============================================================================
-- LYXAL OS — CORE VALIDATIONS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/object_execute.surql
-- Fonction : fn::validation_object_execute
--
-- Valide un objet champ par champ selon un schéma du moteur ({ fields: {
-- <champ>: { pipeline, required, nullable, default } }, unknown_keys }) dont
-- les pipelines utilisent le catalogue de validation. Renvoie le rapport {
-- valid, value, errors, warnings, by_field } ; une valeur qui n'est pas un
-- objet donne l'erreur de fn::validation_object.
--
-- Paramètres
--   $value     : any
--   $schema    : object
--   $max_steps : int
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions validations)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT / CORE_UNSUPPORTED_OPTION : schéma invalide (fn::utils_engine_schema)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_object_execute(
    $value: any,
    $schema: object,
    $max_steps: int
) -> object {
    LET $normalized = fn::utils_engine_schema($schema, fn::validation_step_catalog(), $max_steps);
    LET $start = fn::utils_engine_state($value, "", NONE);
    LET $checked = fn::validation_object($value);
    RETURN fn::utils_engine_report(IF $checked.valid {
        fn::utils_engine_run_object($start, $normalized, |$current, $step| fn::validation_step_apply($current, $step))
    } ELSE {
        fn::utils_engine_issue($start, "is_object", $checked.code, $checked.details)
    });
}
COMMENT "Valide un objet champ par champ selon un schéma du moteur ({ fields: { <champ>: { pipeline, required, nullable, default } }, unknown_keys }) dont les pipelines utilisent le catalogue de validation. Renvoie le rapport { valid, value, errors, warnings, by_field } ; une valeur qui n'est pas un objet donne l'erreur de fn::validation_object."
PERMISSIONS FULL;
