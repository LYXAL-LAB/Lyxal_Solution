-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/extension.surql
-- Fonction : fn::validation_extension
--
-- Valide une extension de fichier ([a-z0-9][a-z0-9._-]*, point initial
-- seulement si autorisé), facultativement parmi une liste ; la valeur
-- renvoyée est en minuscules.
--
-- Paramètres
--   $value              : any — valeur à contrôler
--   $allowed_extensions : option<array<string>> — extensions autorisées (au moins une), NONE pour toutes
--   $allow_leading_dot  : bool — true pour exiger la forme « .pdf », false pour « pdf »
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'extension en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou extension vide
--
-- Exemple (dans une fonction de module)
--   LET $ext = fn::validation_extension($params.extension, ["pdf", "png"], false);
--   IF !$ext.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $ext.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_extension(
    $value: any,
    $allowed_extensions: option<array<string>>,
    $allow_leading_dot: bool
) -> object {
    LET $allowed = IF $allowed_extensions IS NONE { NONE } ELSE { array::map($allowed_extensions, |$item| string::lowercase(string::trim($item))) };
    IF $allowed IS NOT NONE AND (array::len($allowed) = 0 OR array::any($allowed, |$item| $item = "")) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, IF $allow_leading_dot { "^\\.[a-z0-9][a-z0-9._-]*$" } ELSE { "^[a-z0-9][a-z0-9._-]*$" }) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "extension" } };
    };
    IF $allowed IS NOT NONE AND $clean NOT IN $allowed {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $allowed } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une extension de fichier ([a-z0-9][a-z0-9._-]*, point initial seulement si autorisé), facultativement parmi une liste ; la valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
