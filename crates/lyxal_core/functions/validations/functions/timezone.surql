-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/timezone.surql
-- Fonction : fn::validation_timezone
--
-- Valide la forme d'un identifiant de fuseau horaire IANA (Zone/Ville, ex.
-- Europe/Paris) ; "UTC" est accepté seulement si autorisé. La forme est
-- vérifiée, pas l'existence du fuseau.
--
-- Paramètres
--   $value     : any — valeur à contrôler
--   $allow_utc : bool — true pour accepter "UTC"
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $zone = fn::validation_timezone($params.timezone, true);
--   IF !$zone.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $zone.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_timezone(
    $value: any,
    $allow_utc: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !($allow_utc AND $clean = "UTC")
        AND !string::matches($clean, "^[A-Za-z]+(?:[._+-][A-Za-z0-9]+)*/[A-Za-z0-9]+(?:[._+-][A-Za-z0-9]+)*(?:/[A-Za-z0-9]+(?:[._+-][A-Za-z0-9]+)*)*$") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "timezone" } }; };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide la forme d'un fuseau horaire IANA. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
