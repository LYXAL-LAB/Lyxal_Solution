-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/surql_function.surql
-- Fonction : fn::validation_surql_function
--
-- Valide un nom de fonction SurrealQL sans le préfixe « fn:: » (segments
-- [A-Za-z_][A-Za-z0-9_]* séparés par « :: ») ; espace de noms exigé si
-- demandé, segments bornés.
--
-- Paramètres
--   $value             : any — valeur à contrôler
--   $require_namespace : bool — true pour exiger au moins un « :: »
--   $max_segments      : int — nombre maximal de segments (>= 1)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_TOO_LONG
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $max_segments < 1
--
-- Exemple (dans une fonction de module)
--   LET $function = fn::validation_surql_function($params.function, true, 4);
--   IF !$function.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $function.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_surql_function(
    $value: any,
    $require_namespace: bool,
    $max_segments: int
) -> object {
    IF $max_segments < 1 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $segments = array::len(string::split($clean, "::"));
    IF string::starts_with($clean, "fn::") OR !string::matches($clean, "^[A-Za-z_][A-Za-z0-9_]*(?:::[A-Za-z_][A-Za-z0-9_]*)*$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_function" } };
    };
    IF $require_namespace AND $segments < 2 {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_function", require_namespace: true } };
    };
    IF $segments > $max_segments {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_segments: $max_segments, segments: $segments } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un nom de fonction SurrealQL sans le préfixe « fn:: » (segments [A-Za-z_][A-Za-z0-9_]* séparés par « :: ») ; espace de noms exigé si demandé, segments bornés. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
