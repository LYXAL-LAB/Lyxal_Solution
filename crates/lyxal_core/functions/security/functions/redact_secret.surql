-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_redact_secret
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_redact_secret(
    $value: string,
    $visible_start: int,
    $visible_end: int
) -> string {
    RETURN fn::security_secret_mask(
        $value,
        $visible_start,
        $visible_end,
        "*"
    );
}
COMMENT "Masque un secret en réutilisant la primitive Security Secrets."
PERMISSIONS FULL;
