-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/date.surql
-- Fonction : fn::validation_date
--
-- Valide une date calendaire : un datetime à minuit UTC (sans heure),
-- facultativement comprise entre deux dates incluses.
--
-- Paramètres
--   $value     : any — valeur à contrôler
--   $min_value : option<datetime> — date minimale incluse (à minuit), NONE pour aucune
--   $max_value : option<datetime> — date maximale incluse (à minuit), NONE pour aucune
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la date d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : borne qui n'est pas à minuit, ou $min_value > $max_value
--
-- Exemple (dans une fonction de module)
--   LET $day = fn::validation_date($params.day, NONE, NONE);
--   IF !$day.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $day.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_date(
    $value: any,
    $min_value: option<datetime>,
    $max_value: option<datetime>
) -> object {
    IF ($min_value IS NOT NONE AND time::format($min_value, "%H%M%S%f") != "000000000000000")
        OR ($max_value IS NOT NONE AND time::format($max_value, "%H%M%S%f") != "000000000000000") {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $min_value IS NOT NONE AND $max_value IS NOT NONE AND $min_value > $max_value { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_datetime($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: type::of($value) } };
    };
    IF time::format($value, "%H%M%S%f") != "000000000000000" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "date" } }; };
    IF $min_value IS NOT NONE AND $value < $min_value { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: $min_value } }; };
    IF $max_value IS NOT NONE AND $value > $max_value { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $max_value } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide une date calendaire (datetime à minuit) bornée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
