-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/weekday.surql
-- Fonction : fn::validation_weekday
--
-- Valide un jour de la semaine ISO 8601 (1 = lundi … 7 = dimanche),
-- facultativement parmi une liste de jours autorisés.
--
-- Paramètres
--   $value        : any — valeur à contrôler
--   $allowed_days : option<array<int>> — jours autorisés (1 à 7, au moins un), NONE pour tous
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'entier d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_TOO_SMALL
--     CORE_VALIDATION_TOO_LARGE
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou jour hors de 1 à 7
--
-- Exemple (dans une fonction de module)
--   LET $day = fn::validation_weekday($params.day, [1, 2, 3, 4, 5]);
--   IF !$day.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $day.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_weekday(
    $value: any,
    $allowed_days: option<array<int>>
) -> object {
    IF $allowed_days IS NOT NONE AND (array::len($allowed_days) = 0 OR array::any($allowed_days, |$day| $day < 1 OR $day > 7)) {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_int($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "int", actual: type::of($value) } };
    };
    IF $value < 1 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SMALL", details: { min: 1 } }; };
    IF $value > 7 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: 7 } }; };
    IF $allowed_days IS NOT NONE AND $value NOT IN $allowed_days { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $allowed_days } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un jour de la semaine ISO (1 à 7). Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
