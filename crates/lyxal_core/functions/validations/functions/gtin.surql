-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/gtin.surql
-- Fonction : fn::validation_gtin
--
-- Valide un code GTIN (GS1 : GTIN-8, GTIN-12/UPC-A, GTIN-13/EAN-13, GTIN-14) :
-- chiffres (espaces et tirets retirés), longueur 8, 12, 13 ou 14, clé de
-- contrôle GS1 modulo 10 exacte.
--
-- Paramètres
--   $value : any — valeur à contrôler
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = les chiffres, sans espace ni tiret, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT  (details.expected : "digits", "gtin_length" ou "gtin_check_digit")
--
-- Exemple (dans une fonction de module)
--   LET $gtin = fn::validation_gtin($params.code_barre);
--   IF !$gtin.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $gtin.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_gtin($value: any) -> object {
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $digits = string::replace(string::replace($clean, " ", ""), "-", "");
    IF !string::matches($digits, "^[0-9]+$") { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "digits" } }; };
    LET $length = string::len($digits);
    IF $length NOT IN [8, 12, 13, 14] {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "gtin_length", length: $length } };
    };
    -- Poids GS1 : 3 pour le chiffre placé juste avant la clé, puis 1, 3, 1… vers la gauche.
    LET $sum = array::fold(<array> (0..($length - 1)), 0, |$acc, $index| {
        LET $digit = <int> string::slice($digits, $index, $index + 1);
        $acc + IF ($length - 1 - $index) % 2 = 1 { $digit * 3 } ELSE { $digit }
    });
    LET $check = <int> string::slice($digits, $length - 1, $length);
    IF (10 - ($sum % 10)) % 10 != $check {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "gtin_check_digit" } };
    };
    RETURN { valid: true, value: $digits, code: NONE, details: {} };
}
COMMENT "Valide un GTIN (8, 12, 13 ou 14 chiffres, clé GS1 modulo 10). Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
