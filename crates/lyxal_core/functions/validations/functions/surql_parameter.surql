-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/surql_parameter.surql
-- Fonction : fn::validation_surql_parameter
--
-- Valide un nom de paramètre SurrealQL sans le « $ »
-- ([A-Za-z_][A-Za-z0-9_]*) ; les noms réservés ["auth", "session", "token",
-- "before", "after", "event", "value", "this", "input"] sont refusés sauf
-- autorisation.
--
-- Paramètres
--   $value          : any — valeur à contrôler
--   $allow_reserved : bool — true pour accepter les noms réservés
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_FORBIDDEN
--
-- Exemple (dans une fonction de module)
--   LET $name = fn::validation_surql_parameter($params.name, false);
--   IF !$name.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $name.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_surql_parameter(
    $value: any,
    $allow_reserved: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, "^[A-Za-z_][A-Za-z0-9_]*$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "surql_identifier" } };
    };
    IF !$allow_reserved AND string::lowercase($clean) IN ["auth", "session", "token", "before", "after", "event", "value", "this", "input"] {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORBIDDEN", details: {} };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un nom de paramètre SurrealQL sans le « $ » ([A-Za-z_][A-Za-z0-9_]*) ; les noms réservés [\"auth\", \"session\", \"token\", \"before\", \"after\", \"event\", \"value\", \"this\", \"input\"] sont refusés sauf autorisation. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
