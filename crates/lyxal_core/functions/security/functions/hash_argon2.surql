-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hash_argon2
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hash_argon2(
    $secret: string
) -> string {
    IF string::len($secret) = 0 {
        THROW "SECURITY_EMPTY_SECRET";
    };
    THROW "SECURITY_NATIVE_PASSWORD_HASH_REQUIRED";
}
COMMENT "Le hachage de mots de passe Argon2id est exclusivement délégué à lyxal_crypto::password::hash_password en Rust."
PERMISSIONS FULL;
