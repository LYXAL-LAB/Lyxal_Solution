-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/uri_scheme.surql
-- Fonction : fn::validation_uri_scheme
--
-- Valide un schéma d'URI (RFC 3986 : lettre puis [a-z0-9+.-]),
-- facultativement parmi une liste ; la valeur renvoyée est en minuscules.
--
-- Paramètres
--   $value           : any — valeur à contrôler
--   $allowed_schemes : option<array<string>> — schémas autorisés (au moins un, valides), NONE pour tous
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le schéma en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou schéma invalide
--
-- Exemple (dans une fonction de module)
--   LET $scheme = fn::validation_uri_scheme($params.scheme, ["https", "sftp"]);
--   IF !$scheme.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $scheme.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_uri_scheme(
    $value: any,
    $allowed_schemes: option<array<string>>
) -> object {
    LET $allowed = IF $allowed_schemes IS NONE { NONE } ELSE { array::map($allowed_schemes, |$item| string::lowercase(string::trim($item))) };
    IF $allowed IS NOT NONE AND (array::len($allowed) = 0 OR array::any($allowed, |$item| !string::matches($item, "^[a-z][a-z0-9+.-]*$"))) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, "^[a-z][a-z0-9+.-]*$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "uri_scheme" } };
    };
    IF $allowed IS NOT NONE AND $clean NOT IN $allowed {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $allowed } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un schéma d'URI (RFC 3986 : lettre puis [a-z0-9+.-]), facultativement parmi une liste ; la valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
