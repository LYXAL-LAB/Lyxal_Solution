-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/time_string.surql
-- Fonction : fn::validation_time_string
--
-- Valide une heure HH:MM (00:00 à 23:59), ou HH:MM:SS si les secondes sont
-- exigées.
--
-- Paramètres
--   $value           : any — valeur à contrôler
--   $require_seconds : bool — true pour exiger le format HH:MM:SS
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $opening = fn::validation_time_string($params.opening, false);
--   IF !$opening.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $opening.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_time_string(
    $value: any,
    $require_seconds: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $pattern = IF $require_seconds { "^([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$" } ELSE { "^([01][0-9]|2[0-3]):[0-5][0-9]$" };
    IF !string::matches($clean, $pattern) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "time_string" } }; };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une heure HH:MM ou HH:MM:SS. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
