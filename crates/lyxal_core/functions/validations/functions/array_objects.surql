-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/array_objects.surql
-- Fonction : fn::validation_array_objects
--
-- Valide qu'une valeur est un tableau d'objets ; les objets vides sont
-- acceptés seulement si autorisé.
--
-- Paramètres
--   $value               : any — valeur à contrôler
--   $allow_empty_objects : bool — true pour accepter un objet vide {}
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le tableau d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_EMPTY
--
-- Exemple (dans une fonction de module)
--   LET $lines = fn::validation_array_objects($params.lines, false);
--   IF !$lines.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $lines.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_objects(
    $value: any,
    $allow_empty_objects: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_array($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "array", actual: type::of($value) } };
    };
    IF !array::all($value, |$item| type::is_object($item)) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { scope: "item", expected: "object" } };
    };
    IF !$allow_empty_objects AND array::any($value, |$item| object::is_empty($item)) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_EMPTY", details: { scope: "item" } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un tableau d'objets. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
