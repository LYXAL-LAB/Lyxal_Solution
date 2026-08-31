-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_sdk_detect
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_sdk_detect(
    $value: string
) -> object {
    RETURN {
        sdk:fn::security_sdk_version(),
        result:fn::security_detect_payload($value)
    };
}
COMMENT "Exécute la détection générique via le SDK."
PERMISSIONS FULL;
