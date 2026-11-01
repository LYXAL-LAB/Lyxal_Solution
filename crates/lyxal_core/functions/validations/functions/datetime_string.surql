-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/datetime_string.surql
-- Fonction : fn::validation_datetime_string
--
-- Valide une chaîne de date et heure, au format RFC 3339 par défaut ou selon
-- un format strftime donné.
--
-- Paramètres
--   $value  : any — valeur à contrôler
--   $format : option<string> — format strftime (ex. "%Y-%m-%d %H:%M"), NONE pour RFC 3339
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
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $format vide
--
-- Exemple (dans une fonction de module)
--   LET $at = fn::validation_datetime_string($params.at, NONE);
--   IF !$at.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $at.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_datetime_string(
    $value: any,
    $format: option<string>
) -> object {
    IF $format IS NOT NONE AND string::trim($format) = "" { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $matches = IF $format IS NONE { string::is_datetime($clean) } ELSE { string::is_datetime($clean, string::trim($format)) };
    IF !$matches { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "datetime_string" } }; };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une chaîne de date et heure. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
