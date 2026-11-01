-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/surql_field_path.surql
-- Fonction : fn::validation_surql_field_path
--
-- Valide un chemin de champ SurrealQL (a.b.c), avec sélecteurs [*] et [n]
-- selon autorisation ; nombre de segments borné.
--
-- Paramètres
--   $value                : any — valeur à contrôler
--   $allow_array_wildcard : bool — accepter le sélecteur [*]
--   $allow_numeric_index  : bool — accepter le sélecteur [n]
--   $max_segments         : int — nombre maximal de segments (>= 1)
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
--   LET $path = fn::validation_surql_field_path($params.path, true, false, 8);
--   IF !$path.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $path.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_surql_field_path(
    $value: any,
    $allow_array_wildcard: bool,
    $allow_numeric_index: bool,
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
    LET $selector = IF $allow_array_wildcard AND $allow_numeric_index { "(?:\\[(?:\\*|[0-9]+)\\])*" }
        ELSE IF $allow_array_wildcard { "(?:\\[\\*\\])*" } ELSE IF $allow_numeric_index { "(?:\\[[0-9]+\\])*" } ELSE { "" };
    LET $segment = "[A-Za-z_][A-Za-z0-9_]*" + $selector;
    LET $segments = array::len(string::split($clean, "."));
    IF !string::matches($clean, "^" + $segment + "(?:\\." + $segment + ")*$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_field_path" } };
    };
    IF $segments > $max_segments {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_segments: $max_segments, segments: $segments } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un chemin de champ SurrealQL (a.b.c), avec sélecteurs [*] et [n] selon autorisation ; nombre de segments borné. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
