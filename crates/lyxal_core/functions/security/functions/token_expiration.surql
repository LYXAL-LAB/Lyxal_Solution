-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/token_expiration.surql
-- Fonction : fn::security_token_expiration
--
-- Calcule l'expiration et le temps restant d'un token.
--
-- Paramètres
--   $issued_at : datetime
--   $ttl       : duration
--   $now       : datetime
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $ttl <= 0s
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_token_expiration(
    $issued_at: datetime,
    $ttl: duration,
    $now: datetime
) -> object {
    IF $ttl <= 0s {
        THROW "CORE_INVALID_ARGUMENT";
    };

    LET $expires_at = $issued_at + $ttl;

    RETURN {
        issued_at: $issued_at,
        expires_at: $expires_at,
        expired: $expires_at <= $now,
        remaining: IF $expires_at <= $now {
            0s
        } ELSE {
            $expires_at - $now
        }
    };
}
COMMENT "Calcule l'expiration et le temps restant d'un token."
PERMISSIONS FULL;
