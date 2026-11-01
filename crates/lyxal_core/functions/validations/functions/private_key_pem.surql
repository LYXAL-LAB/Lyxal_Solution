-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/private_key_pem.surql
-- Fonction : fn::validation_private_key_pem
--
-- Valide l'enveloppe PEM d'une clé privée (PRIVATE KEY, RSA, EC ; chiffrée
-- seulement si autorisé) ; le contenu n'est pas décodé.
--
-- Paramètres
--   $value           : any — valeur à contrôler
--   $allow_encrypted : bool — accepter une clé chiffrée (ENCRYPTED PRIVATE KEY)
--   $max_length      : int — longueur maximale (>= 1)
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = la chaîne sans espaces périphériques, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_TOO_LONG
--     CORE_VALIDATION_NOT_ALLOWED
--     CORE_VALIDATION_FORMAT
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $max_length < 1
--
-- Exemple (dans une fonction de module)
--   LET $pem = fn::validation_private_key_pem($params.pem, false, 65536);
--   IF !$pem.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $pem.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_private_key_pem(
    $value: any,
    $allow_encrypted: bool,
    $max_length: int
) -> object {
    IF $max_length < 1 { THROW "CORE_INVALID_ARGUMENT"; };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $clean = string::trim($value);
    IF $clean = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $length = string::len($clean);
    IF $max_length IS NOT NONE AND $length > $max_length { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: $max_length, length: $length } }; };
    IF !$allow_encrypted AND string::starts_with($clean, "-----BEGIN ENCRYPTED PRIVATE KEY-----") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "encrypted" } };
    };
    IF !((string::starts_with($clean, "-----BEGIN PRIVATE KEY-----") AND string::ends_with($clean, "-----END PRIVATE KEY-----")) OR (string::starts_with($clean, "-----BEGIN RSA PRIVATE KEY-----") AND string::ends_with($clean, "-----END RSA PRIVATE KEY-----")) OR (string::starts_with($clean, "-----BEGIN EC PRIVATE KEY-----") AND string::ends_with($clean, "-----END EC PRIVATE KEY-----")) OR (string::starts_with($clean, "-----BEGIN ENCRYPTED PRIVATE KEY-----") AND string::ends_with($clean, "-----END ENCRYPTED PRIVATE KEY-----")))
        OR !string::contains($clean, "\n") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "private_key_pem" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide l'enveloppe PEM d'une clé privée (PRIVATE KEY, RSA, EC ; chiffrée seulement si autorisé) ; le contenu n'est pas décodé. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
