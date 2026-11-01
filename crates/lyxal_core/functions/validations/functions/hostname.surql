-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/hostname.surql
-- Fonction : fn::validation_hostname
--
-- Valide un nom d'hôte (RFC 1123 : labels de 1 à 63 caractères [a-z0-9-],
-- 253 au total) ; un nom à un seul label est accepté seulement si autorisé.
-- La valeur renvoyée est en minuscules.
--
-- Paramètres
--   $value              : any — valeur à contrôler
--   $allow_single_label : bool — true pour accepter un nom sans point (ex. localhost)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le nom d'hôte en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Exemple (dans une fonction de module)
--   LET $host = fn::validation_hostname($params.host, false);
--   IF !$host.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $host.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_hostname(
    $value: any,
    $allow_single_label: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF string::len($clean) > 253
        OR array::any(string::split($clean, "."), |$label| string::len($label) > 63 OR !string::matches($label, "^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$")) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "hostname" } };
    };
    IF !$allow_single_label AND array::len(string::split($clean, ".")) < 2 {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "single_label" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un nom d'hôte (RFC 1123 : labels de 1 à 63 caractères [a-z0-9-], 253 au total) ; un nom à un seul label est accepté seulement si autorisé. La valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
