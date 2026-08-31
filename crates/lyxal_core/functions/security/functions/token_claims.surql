-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_token_claims
-- Version  : 1.0.0
-- Statut   : Stable
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
        THROW "SECURITY_INVALID_TOKEN_CLAIM_DATES";
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
