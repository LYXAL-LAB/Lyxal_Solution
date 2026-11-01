-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/iso8601.surql
-- Fonction : fn::validation_iso8601
--
-- Valide une chaîne de date et heure ISO 8601 complète (AAAA-MM-JJTHH:MM:SS,
-- puis Z ou décalage ±HH:MM), fractions de seconde acceptées seulement si
-- autorisé.
--
-- Paramètres
--   $value                    : any — valeur à contrôler
--   $allow_fractional_seconds : bool — true pour accepter les fractions de seconde
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
--   LET $at = fn::validation_iso8601($params.at, true);
--   IF !$at.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $at.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_iso8601(
    $value: any,
    $allow_fractional_seconds: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $pattern = IF $allow_fractional_seconds {
        "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]+)?(Z|[+-][0-9]{2}:[0-9]{2})$"
    } ELSE {
        "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(Z|[+-][0-9]{2}:[0-9]{2})$"
    };
    IF !string::matches($clean, $pattern) OR !string::is_datetime($clean) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "iso8601" } }; };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une chaîne ISO 8601 complète. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
