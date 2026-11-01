-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/storage_path.surql
-- Fonction : fn::validation_storage_path
--
-- Valide un chemin de stockage ([A-Za-z0-9._~/-], sans « .. », « // » ni
-- barre oblique inverse), barres obliques initiale et finale selon
-- autorisation ; longueur bornée.
--
-- Paramètres
--   $value                : any — valeur à contrôler
--   $allow_leading_slash  : bool — accepter une barre oblique initiale
--   $allow_trailing_slash : bool — accepter une barre oblique finale
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
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $max_length < 1
--
-- Exemple (dans une fonction de module)
--   LET $path = fn::validation_storage_path($params.path, false, false, 1024);
--   IF !$path.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $path.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_storage_path(
    $value: any,
    $allow_leading_slash: bool,
    $allow_trailing_slash: bool,
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
    IF (!$allow_leading_slash AND string::starts_with($clean, "/")) OR (!$allow_trailing_slash AND string::ends_with($clean, "/"))
        OR string::contains($clean, "//") OR string::contains($clean, "..") OR string::contains($clean, "\\") OR !string::matches($clean, "^[A-Za-z0-9._~/-]+$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "storage_path" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un chemin de stockage ([A-Za-z0-9._~/-], sans « .. », « // » ni barre oblique inverse), barres obliques initiale et finale selon autorisation ; longueur bornée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
