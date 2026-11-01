-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/birthdate.surql
-- Fonction : fn::validation_birthdate
--
-- Valide une date de naissance : date calendaire (à minuit UTC) qui n'est
-- pas dans le futur ; le jour même est accepté seulement si autorisé.
--
-- Paramètres
--   $value       : any — valeur à contrôler
--   $allow_today : bool — true pour accepter la date du jour
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la date d'origine, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_TOO_LARGE
--
-- Exemple (dans une fonction de module)
--   LET $birthdate = fn::validation_birthdate($params.birthdate, false);
--   IF !$birthdate.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $birthdate.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_birthdate(
    $value: any,
    $allow_today: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_datetime($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "datetime", actual: type::of($value) } };
    };
    IF time::format($value, "%H%M%S%f") != "000000000000000" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "date" } }; };
    LET $today = time::floor(time::now(), 1d);
    IF $value > $today OR (!$allow_today AND $value = $today) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LARGE", details: { max: $today, exclusive: !$allow_today } };
    };
    RETURN { valid: true, value: $value, code: NONE, details: {} };
}
COMMENT "Valide une date de naissance passée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
