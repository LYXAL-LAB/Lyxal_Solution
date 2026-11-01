-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/mac_address.surql
-- Fonction : fn::validation_mac_address
--
-- Valide une adresse MAC (6 octets hexadécimaux séparés par « : » ou « - »,
-- selon les séparateurs autorisés) ; la valeur renvoyée est en minuscules.
--
-- Paramètres
--   $value        : any — valeur à contrôler
--   $allow_hyphen : bool — accepter le séparateur « - »
--   $allow_colon  : bool — accepter le séparateur « : »
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'adresse en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : aucun séparateur autorisé
--
-- Exemple (dans une fonction de module)
--   LET $mac = fn::validation_mac_address($params.mac, true, true);
--   IF !$mac.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $mac.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_mac_address(
    $value: any,
    $allow_hyphen: bool,
    $allow_colon: bool
) -> object {
    IF !$allow_hyphen AND !$allow_colon { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::lowercase(string::trim($value));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !($allow_colon AND string::matches($clean, "^([0-9a-f]{2}:){5}[0-9a-f]{2}$"))
        AND !($allow_hyphen AND string::matches($clean, "^([0-9a-f]{2}-){5}[0-9a-f]{2}$")) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "mac_address" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide une adresse MAC (6 octets hexadécimaux séparés par « : » ou « - », selon les séparateurs autorisés) ; la valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
