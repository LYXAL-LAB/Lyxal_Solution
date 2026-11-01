-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/lyxal_storage_path.surql
-- Fonction : fn::validation_lyxal_storage_path
--
-- Valide un chemin de stockage Lyxal relatif (segments [A-Za-z0-9._-]
-- séparés par « / », sans « .. ») ; extension de fichier selon autorisation,
-- racine facultativement imposée ; longueur bornée.
--
-- Paramètres
--   $value                : any — valeur à contrôler
--   $required_root        : option<string> — premier segment exigé (non vide), NONE pour aucun
--   $allow_file_extension : bool — true pour accepter une extension sur le dernier segment
--   $max_length           : int — longueur maximale (>= 1)
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
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $max_length < 1 ou racine vide
--
-- Exemple (dans une fonction de module)
--   LET $path = fn::validation_lyxal_storage_path($params.path, "tenants", true, 1024);
--   IF !$path.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $path.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_storage_path(
    $value: any,
    $required_root: option<string>,
    $allow_file_extension: bool,
    $max_length: int
) -> object {
    IF $max_length < 1 { THROW "CORE_INVALID_ARGUMENT"; };
    LET $root = IF $required_root IS NONE { NONE } ELSE { string::trim($required_root) };
    IF $root IS NOT NONE AND $root = "" { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $length = string::len($clean);
    IF $max_length IS NOT NONE AND $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    IF !string::matches($clean, "^[A-Za-z0-9._-]+(?:/[A-Za-z0-9._-]+)*$") OR string::contains($clean, "..") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_storage_path" } };
    };
    IF !$allow_file_extension AND string::matches($clean, "(?:^|/)[^/]+\\.[A-Za-z0-9]+$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "extension" } };
    };
    IF $root IS NOT NONE AND !string::starts_with($clean, $root + "/") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "lyxal_storage_path", root: $root } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un chemin de stockage Lyxal relatif (segments [A-Za-z0-9._-] séparés par « / », sans « .. ») ; extension de fichier selon autorisation, racine facultativement imposée ; longueur bornée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
