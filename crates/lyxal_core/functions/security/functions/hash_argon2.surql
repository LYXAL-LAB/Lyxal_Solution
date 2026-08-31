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
    RETURN crypto::argon2::generate($secret);
}
COMMENT "Génère un hash Argon2 salé pour un secret ou mot de passe."
PERMISSIONS FULL;
