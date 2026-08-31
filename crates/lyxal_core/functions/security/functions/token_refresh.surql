-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_token_refresh
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_token_refresh(
    $old_token_id: uuid,
    $new_token_id: uuid,
    $rotated_at: datetime,
    $old_valid_until: datetime
) -> object {
    IF $old_valid_until < $rotated_at {
        THROW "SECURITY_INVALID_TOKEN_GRACE_WINDOW";
    };

    RETURN {
        old_token_id: $old_token_id,
        new_token_id: $new_token_id,
        rotated_at: $rotated_at,
        old_valid_until: $old_valid_until,
        status: "rotated"
    };
}
COMMENT "Construit une relation de rotation entre deux tokens."
PERMISSIONS FULL;
