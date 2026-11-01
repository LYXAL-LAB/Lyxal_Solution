-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/archive_entry_path.surql
-- Fonction : fn::validation_archive_entry_path
--
-- Valide le chemin d'une entrée d'archive (relatif, sans « .. », « // »,
-- barre oblique inverse ni lettre de lecteur), de longueur bornée.
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
--   LET $entry = fn::validation_archive_entry_path($entry_name, 1024);
--   IF !$entry.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $entry.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_archive_entry_path(
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
    IF string::starts_with($clean, "/") OR string::contains($clean, "..") OR string::contains($clean, "\\") OR string::contains($clean, "//") OR string::matches($clean, "^[A-Za-z]:") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "archive_entry_path" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide le chemin d'une entrée d'archive (relatif, sans « .. », « // », barre oblique inverse ni lettre de lecteur), de longueur bornée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
