-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/content_type.surql
-- Fonction : fn::validation_content_type
--
-- Valide un en-tête Content-Type (type/sous-type, paramètres « ; … »
-- acceptés), facultativement parmi une liste de types de média ; la valeur
-- renvoyée est en minuscules.
--
-- Paramètres
--   $value               : any — valeur à contrôler
--   $allowed_media_types : option<array<string>> — types de média autorisés (au moins un), NONE pour tous
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'en-tête en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou valeur vide
--
-- Exemple (dans une fonction de module)
--   LET $type = fn::validation_content_type($headers.content_type, ["application/json"]);
--   IF !$type.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $type.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_content_type(
    $value: any,
    $allowed_media_types: option<array<string>>
) -> object {
    LET $allowed = IF $allowed_media_types IS NONE { NONE } ELSE { array::map($allowed_media_types, |$item| string::lowercase(string::trim($item))) };
    IF $allowed IS NOT NONE AND (array::len($allowed) = 0 OR array::any($allowed, |$item| $item = "")) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $media_type = string::trim(string::split($clean, ";")[0]);
    IF !string::matches($media_type, "^[a-z0-9!#$&^_.+-]+/[a-z0-9!#$&^_.+-]+$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "content_type" } };
    };
    IF $allowed IS NOT NONE AND $media_type NOT IN $allowed {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $allowed } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un en-tête Content-Type (type/sous-type, paramètres « ; … » acceptés), facultativement parmi une liste de types de média ; la valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
