-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/token_generate.surql
-- Fonction : fn::security_token_generate
--
-- Génère un token opaque textuel avec UUID v7, date d'émission et
-- expiration.
--
-- Paramètres
--   $prefix    : string
--   $length    : int
--   $issued_at : datetime
--   $ttl       : duration
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $length < 24 OR $length > 256
--   CORE_INVALID_ARGUMENT : $ttl <= 0s
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_token_generate(
    $prefix: string,
    $length: int,
    $issued_at: datetime,
    $ttl: duration
) -> object {
    IF $length < 24 OR $length > 256 {
        THROW "CORE_INVALID_ARGUMENT";
    };
    IF $ttl <= 0s {
        THROW "CORE_INVALID_ARGUMENT";
    };

    LET $clean_prefix = string::lowercase(string::trim($prefix));
    LET $token_id = rand::uuid::v7();
    LET $secret = rand::id($length);

    RETURN {
        token_id: $token_id,
        token: IF $clean_prefix = "" {
            $secret
        } ELSE {
            string::concat($clean_prefix, "_", $secret)
        },
        issued_at: $issued_at,
        expires_at: $issued_at + $ttl,
        status: "active"
    };
}
COMMENT "Génère un token opaque textuel avec UUID v7, date d'émission et expiration."
PERMISSIONS FULL;
