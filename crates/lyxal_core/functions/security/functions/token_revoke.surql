-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_token_revoke
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_token_revoke(
    $token_id: uuid,
    $revoked_at: datetime,
    $reason: string,
    $actor: option<string>
) -> object {
    RETURN {
        token_id: $token_id,
        status: "revoked",
        revoked_at: $revoked_at,
        reason: string::trim($reason),
        actor: IF $actor IS NONE { NONE } ELSE { string::trim($actor) }
    };
}
COMMENT "Construit un événement de révocation de token."
PERMISSIONS FULL;
