-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/luhn.surql
-- Fonction : fn::validation_luhn
--
-- Valide un numéro protégé par la clé de Luhn (carte bancaire, SIREN,
-- SIRET…) : chiffres (espaces et tirets retirés), longueur bornée, somme de
-- contrôle exacte.
--
-- Paramètres
--   $value      : any — valeur à contrôler
--   $min_length : int — longueur minimale (>= 1)
--   $max_length : int — longueur maximale (>= $min_length)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = les chiffres, sans espace ni tiret, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $min_length < 1 ou $min_length > $max_length
--
-- Exemple (dans une fonction de module)
--   LET $number = fn::validation_luhn($params.number, 12, 19);
--   IF !$number.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $number.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_luhn(
    $value: any,
    $min_length: int,
    $max_length: int
) -> object {
    IF $min_length < 1 OR $min_length > $max_length { THROW "CORE_INVALID_ARGUMENT"; };
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
    IF $length < $min_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_SHORT", details: { min_length: $min_length, length: $length } }; };
    IF $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    LET $sum = array::fold(<array> (0..$length), 0, |$acc, $index| {
        LET $digit = <int> string::slice($digits, $index, $index + 1);
        LET $weighted = IF ($length - $index) % 2 = 0 { $digit * 2 } ELSE { $digit };
        $acc + IF $weighted > 9 { $weighted - 9 } ELSE { $weighted }
    });
    IF $sum % 10 != 0 { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "luhn" } }; };
    RETURN { valid: true, value: $digits, code: NONE, details: {} };
}
COMMENT "Valide un numéro à clé de Luhn. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
