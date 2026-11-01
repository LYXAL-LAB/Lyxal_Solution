-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/etag.surql
-- Fonction : fn::validation_etag
--
-- Valide une valeur d'en-tête ETag ("…" ou W/"…") ; un ETag faible est
-- accepté seulement si autorisé.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $allow_weak : bool — true pour accepter un ETag faible (W/)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_NOT_ALLOWED
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $etag = fn::validation_etag($headers.if_match, false);
--   IF !$etag.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $etag.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_etag(
    $value: any,
    $allow_weak: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF string::starts_with($clean, "W/") AND !$allow_weak {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "weak" } };
    };
    IF !string::matches($clean, "^(W/)?\"[\\x21\\x23-\\x7E\\x80-\\xFF]*\"$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "etag" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une valeur d'en-tête ETag (\"…\" ou W/\"…\") ; un ETag faible est accepté seulement si autorisé. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
