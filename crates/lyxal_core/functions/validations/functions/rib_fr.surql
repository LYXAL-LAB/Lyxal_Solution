-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/rib_fr.surql
-- Fonction : fn::validation_rib_fr
--
-- Valide la forme d'un RIB français : code banque (5 chiffres), code guichet
-- (5 chiffres), numéro de compte (11 caractères alphanumériques) et clé (2
-- chiffres), espaces retirés. La clé RIB n'est pas recalculée.
--
-- Paramètres
--   $bank_code      : any — code banque
--   $branch_code    : any — code guichet
--   $account_number : any — numéro de compte
--   $rib_key        : any — clé RIB
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { bank_code, branch_code, account_number, rib_key }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_FORMAT
--
-- Exemple (dans une fonction de module)
--   LET $rib = fn::validation_rib_fr($params.bank_code, $params.branch_code, $params.account_number, $params.rib_key);
--   IF !$rib.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $rib.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_rib_fr(
    $bank_code: any,
    $branch_code: any,
    $account_number: any,
    $rib_key: any
) -> object {
    IF $bank_code IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "bank_code" } }; };
    IF type::is_null($bank_code) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "bank_code" } }; };
    IF !type::is_string($bank_code) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "bank_code", expected: "string", actual: type::of($bank_code) } };
    };
    LET $bank_code_clean = string::replace(string::trim($bank_code), " ", "");
    IF !string::matches($bank_code_clean, "^[0-9]{5}$") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { bound: "bank_code", expected: "^[0-9]{5}$" } }; };
    IF $branch_code IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "branch_code" } }; };
    IF type::is_null($branch_code) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "branch_code" } }; };
    IF !type::is_string($branch_code) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "branch_code", expected: "string", actual: type::of($branch_code) } };
    };
    LET $branch_code_clean = string::replace(string::trim($branch_code), " ", "");
    IF !string::matches($branch_code_clean, "^[0-9]{5}$") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { bound: "branch_code", expected: "^[0-9]{5}$" } }; };
    IF $account_number IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "account_number" } }; };
    IF type::is_null($account_number) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "account_number" } }; };
    IF !type::is_string($account_number) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "account_number", expected: "string", actual: type::of($account_number) } };
    };
    LET $account_number_clean = string::uppercase(string::replace(string::trim($account_number), " ", ""));
    IF !string::matches($account_number_clean, "^[A-Z0-9]{11}$") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { bound: "account_number", expected: "^[A-Z0-9]{11}$" } }; };
    IF $rib_key IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "rib_key" } }; };
    IF type::is_null($rib_key) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: { bound: "rib_key" } }; };
    IF !type::is_string($rib_key) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "rib_key", expected: "string", actual: type::of($rib_key) } };
    };
    LET $rib_key_clean = string::replace(string::trim($rib_key), " ", "");
    IF !string::matches($rib_key_clean, "^[0-9]{2}$") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { bound: "rib_key", expected: "^[0-9]{2}$" } }; };
    RETURN { valid: true, value: { bank_code: $bank_code_clean, branch_code: $branch_code_clean, account_number: $account_number_clean, rib_key: $rib_key_clean }, code: NONE, details: {} };
}
COMMENT "Valide la forme d'un RIB français. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
