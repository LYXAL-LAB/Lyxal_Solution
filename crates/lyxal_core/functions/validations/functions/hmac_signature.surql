-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/hmac_signature.surql
-- Fonction : fn::validation_hmac_signature
--
-- Valide la forme d'une signature HMAC encodée en hexadécimal ou en Base64,
-- de longueur facultativement imposée (la signature n'est pas vérifiée :
-- voir lyxal_crypto).
--
-- Paramètres
--   $value           : any — valeur à contrôler
--   $encoding        : string — "hex" ou "base64", insensible à la casse
--   $expected_length : option<int> — longueur exacte attendue (>= 1), NONE pour aucune
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la signature (en minuscules si hexadécimale), code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : encodage inconnu
--   CORE_INVALID_ARGUMENT : $expected_length < 1
--
-- Exemple (dans une fonction de module)
--   LET $signature = fn::validation_hmac_signature($headers.signature, "hex", 64);
--   IF !$signature.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $signature.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_hmac_signature(
    $value: any,
    $encoding: string,
    $expected_length: option<int>
) -> object {
    LET $mode = string::lowercase(string::trim($encoding));
    IF $mode NOT IN ["hex", "base64"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    IF $expected_length IS NOT NONE AND $expected_length < 1 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    IF !string::matches($clean, IF $mode = "hex" { "^[0-9A-Fa-f]+$" } ELSE { "^[A-Za-z0-9+/]+={0,2}$" }) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: $mode } };
    };
    IF $expected_length IS NOT NONE AND string::len($clean) != $expected_length {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: $mode, length: $expected_length } };
    };
    RETURN { valid: true, value: IF $mode = "hex" { string::lowercase($clean) } ELSE { $clean }, code: NONE, details: {} };
}
COMMENT "Valide la forme d'une signature HMAC encodée en hexadécimal ou en Base64, de longueur facultativement imposée (la signature n'est pas vérifiée : voir lyxal_crypto). Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
