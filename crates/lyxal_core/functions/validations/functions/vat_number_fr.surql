-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/vat_number_fr.surql
-- Fonction : fn::validation_vat_number_fr
--
-- Valide un numéro de TVA intracommunautaire français (FR + clé de 2
-- caractères + SIREN valide) ; la clé numérique est vérifiée si demandé.
--
-- Paramètres
--   $value                : any — valeur à contrôler
--   $validate_numeric_key : bool — true pour vérifier une clé numérique : (12 + 3 × (SIREN mod 97)) mod 97
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { vat_number, country, key, siren }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $vat = fn::validation_vat_number_fr($params.vat_number, true);
--   IF !$vat.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $vat.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_vat_number_fr(
    $value: any,
    $validate_numeric_key: bool
) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $vat = string::uppercase(string::replace(string::trim($value), " ", ""));
    IF $vat = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($vat, "^FR[A-Z0-9]{2}[0-9]{9}$") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "vat_number_fr" } }; };
    LET $key = string::slice($vat, 2, 4);
    LET $siren = string::slice($vat, 4, 13);
    IF !fn::validation_siren($siren).valid { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "siren" } }; };
    IF $validate_numeric_key AND string::matches($key, "^[0-9]{2}$") AND <int> $key != (12 + 3 * (<int> $siren % 97)) % 97 {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "vat_key" } };
    };
    RETURN { valid: true, value: { vat_number: $vat, country: "FR", key: $key, siren: $siren }, code: NONE, details: {} };
}
COMMENT "Valide un numéro de TVA français. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
