-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/iban.surql
-- Fonction : fn::validation_iban
--
-- Valide la forme d'un IBAN (espaces retirés, majuscules) et sa longueur
-- pour les pays connus (FR, BE, DE, ES, IT, LU, NL, PT, GB, CH) ; pays
-- facultativement limités. La clé de contrôle modulo 97 n'est pas vérifiée.
--
-- Paramètres
--   $value             : any — valeur à contrôler
--   $allowed_countries : option<array<string>> — codes pays autorisés (au moins un, au bon format), NONE pour tous
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'IBAN sans espace, en majuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou code pays au mauvais format
--
-- Exemple (dans une fonction de module)
--   LET $iban = fn::validation_iban($params.iban, ["FR"]);
--   IF !$iban.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $iban.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_iban(
    $value: any,
    $allowed_countries: option<array<string>>
) -> object {
    LET $allowed = IF $allowed_countries IS NONE { NONE } ELSE { array::map($allowed_countries, |$item| string::uppercase(string::trim($item))) };
    IF $allowed IS NOT NONE AND (array::len($allowed) = 0 OR array::any($allowed, |$item| !string::matches($item, "^[A-Z]{2}$"))) { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::uppercase(string::replace(string::trim($value), " ", ""));
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $country = string::slice($clean, 0, 2);
    LET $expected_length = { FR: 27, BE: 16, DE: 22, ES: 24, IT: 27, LU: 20, NL: 18, PT: 25, GB: 22, CH: 21 }[$country];
    IF !string::matches($clean, "^[A-Z]{2}[0-9]{2}[A-Z0-9]{11,30}$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "iban" } };
    };
    IF $expected_length IS NOT NONE AND string::len($clean) != $expected_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "iban", length: $expected_length } };
    };
    IF $allowed IS NOT NONE AND $country NOT IN $allowed {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $allowed } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide la forme d'un IBAN (espaces retirés, majuscules) et sa longueur pour les pays connus (FR, BE, DE, ES, IT, LU, NL, PT, GB, CH) ; pays facultativement limités. La clé de contrôle modulo 97 n'est pas vérifiée. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
