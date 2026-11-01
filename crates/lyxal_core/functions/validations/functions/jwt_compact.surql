-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/jwt_compact.surql
-- Fonction : fn::validation_jwt_compact
--
-- Valide la forme compacte d'un JWT : trois segments Base64URL non vides
-- séparés par des points (la signature n'est pas vérifiée).
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $max_length : int — longueur maximale (>= 1)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_TOO_LONG
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $max_length < 1
--
-- Exemple (dans une fonction de module)
--   LET $jwt = fn::validation_jwt_compact($params.token, 8192);
--   IF !$jwt.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $jwt.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_jwt_compact(
    $value: any,
    $max_length: int
) -> object {
    IF $max_length < 1 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $length = string::len($clean);
    IF $max_length IS NOT NONE AND $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    IF array::len(string::split($clean, ".")) != 3
        OR !array::all(string::split($clean, "."), |$segment| string::matches($segment, "^[A-Za-z0-9_-]+$")) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "jwt_compact" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide la forme compacte d'un JWT : trois segments Base64URL non vides séparés par des points (la signature n'est pas vérifiée). Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
