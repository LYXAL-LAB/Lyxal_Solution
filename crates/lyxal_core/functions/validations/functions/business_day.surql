-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/business_day.surql
-- Fonction : fn::validation_business_day
--
-- Valide un jour ouvré : date calendaire (à minuit UTC) qui n'est ni un
-- samedi, ni un dimanche, ni un jour férié fourni.
--
-- Paramètres
--   $value    : any — valeur à contrôler
--   $holidays : option<array<datetime>> — jours fériés (dates à minuit), NONE pour aucun
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la date d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : jour férié qui n'est pas à minuit
--
-- Exemple (dans une fonction de module)
--   LET $day = fn::validation_business_day($params.delivery_day, $holidays);
--   IF !$day.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $day.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_business_day(
    $value: any,
    $holidays: option<array<datetime>>
) -> object {
    IF $holidays IS NOT NONE AND array::any($holidays, |$holiday| time::format($holiday, "%H%M%S%f") != "000000000000000") {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_datetime($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: type::of($value) } };
    };
    IF time::format($value, "%H%M%S%f") != "000000000000000" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "date" } }; };
    IF <int> time::format($value, "%w") IN [0, 6] { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "weekend" } }; };
    IF $holidays IS NOT NONE AND $value IN $holidays { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "holiday" } }; };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide un jour ouvré (ni week-end ni jour férié). Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
