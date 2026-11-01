-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/checksum.surql
-- Fonction : fn::validation_checksum
--
-- Valide une empreinte hexadécimale dont la longueur correspond à
-- l'algorithme (crc32, md5, sha1, sha256, sha384, sha512) ; la valeur
-- renvoyée est en minuscules.
--
-- Paramètres
--   $value     : any — valeur à contrôler
--   $algorithm : string — crc32 | md5 | sha1 | sha256 | sha384 | sha512, insensible à la casse
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = l'empreinte en minuscules, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : algorithme inconnu
--
-- Exemple (dans une fonction de module)
--   LET $digest = fn::validation_checksum($params.digest, "sha256");
--   IF !$digest.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $digest.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_checksum(
    $value: any,
    $algorithm: string
) -> object {
    LET $algo = string::lowercase(string::trim($algorithm));
    LET $expected_length = { crc32: 8, md5: 32, sha1: 40, sha256: 64, sha384: 96, sha512: 128 }[$algo];
    IF $expected_length IS NONE { THROW "CORE_UNSUPPORTED_OPTION"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, "^[0-9A-Fa-f]+$") OR string::len($clean) != $expected_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: $algo, length: $expected_length } };
    };
    RETURN { valid: true, value: string::lowercase($clean), code: NONE, details: {} };
}
COMMENT "Valide une empreinte hexadécimale dont la longueur correspond à l'algorithme (crc32, md5, sha1, sha256, sha384, sha512) ; la valeur renvoyée est en minuscules. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
