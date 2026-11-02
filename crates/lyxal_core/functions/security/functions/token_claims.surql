-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/token_claims.surql
-- Fonction : fn::security_token_claims
--
-- Construit un ensemble normalisé de claims.
--
-- Paramètres
--   $subject    : string
--   $audience   : array<string>
--   $scopes     : array<string>
--   $issued_at  : datetime
--   $expires_at : datetime
--   $extra      : option<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $expires_at <= $issued_at
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_token_claims(
    $subject: string,
    $audience: array<string>,
    $scopes: array<string>,
    $issued_at: datetime,
    $expires_at: datetime,
    $extra: option<object>
) -> object {
    IF $expires_at <= $issued_at {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN object::extend(
        {
            sub: string::trim($subject),
            aud: array::distinct($audience),
            scope: array::distinct($scopes),
            iat: time::unix($issued_at),
            exp: time::unix($expires_at),
            jti: <string>rand::uuid::v7()
        },
        IF $extra IS NONE { {} } ELSE { $extra }
    );
}
COMMENT "Construit un ensemble normalisé de claims."
PERMISSIONS FULL;
