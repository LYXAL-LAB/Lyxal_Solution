-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/past_datetime.surql
-- Fonction : fn::validation_past_datetime
--
-- Valide qu'un datetime est dans le passé par rapport à une référence (par
-- défaut maintenant), avec une ancienneté minimale et maximale facultative.
--
-- Paramètres
--   $value           : any — valeur à contrôler
--   $reference_value : option<datetime> — instant de référence, NONE pour time::now()
--   $allow_equal     : bool — true pour accepter un instant égal à la référence
--   $min_age         : option<duration> — écart minimal avec la référence, NONE pour aucun
--   $max_age         : option<duration> — écart maximal avec la référence, NONE pour aucun
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le datetime d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_age > $max_age, ou $max_age = 0ns sans $allow_equal
--
-- Exemple (dans une fonction de module)
--   LET $at = fn::validation_past_datetime($params.at, NONE, false, NONE, NONE);
--   IF !$at.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $at.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_past_datetime(
    $value: any,
    $reference_value: option<datetime>,
    $allow_equal: bool,
    $min_age: option<duration>,
    $max_age: option<duration>
) -> object {
    IF $min_age IS NOT NONE AND $max_age IS NOT NONE AND $min_age > $max_age { THROW "CORE_INVALID_ARGUMENT"; };
    IF !$allow_equal AND $max_age IS NOT NONE AND $max_age = 0ns { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_datetime($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: type::of($value) } };
    };
    LET $reference = $reference_value ?? time::now();
    IF ($allow_equal AND $value > $reference) OR (!$allow_equal AND $value >= $reference) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $reference, exclusive: !$allow_equal } };
    };
    LET $age = $reference - $value;
    IF $min_age IS NOT NONE AND $age < $min_age { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min_age: $min_age, age: $age } }; };
    IF $max_age IS NOT NONE AND $age > $max_age { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max_age: $max_age, age: $age } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide qu'un datetime est dans le passé par rapport à une référence (par défaut maintenant), avec une ancienneté minimale et maximale facultative. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
