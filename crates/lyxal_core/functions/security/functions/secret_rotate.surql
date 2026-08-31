-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_secret_rotate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_secret_rotate(
    $current_reference: string,
    $new_reference: string,
    $valid_from: datetime,
    $grace_period: duration
) -> object {
    IF $grace_period < 0s {
        THROW "SECURITY_INVALID_SECRET_GRACE_PERIOD";
    };

    RETURN {
        current_reference: string::trim($current_reference),
        new_reference: string::trim($new_reference),
        valid_from: $valid_from,
        previous_valid_until: $valid_from + $grace_period,
        status: "scheduled"
    };
}
COMMENT "Construit un plan de rotation de secret par références."
PERMISSIONS FULL;
