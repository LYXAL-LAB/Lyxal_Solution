-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_sdk_capabilities
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_sdk_capabilities()
    -> array<string> {
    RETURN [
        "hash",
        "hmac_contracts",
        "secrets",
        "tokens",
        "signatures",
        "encryption_contracts",
        "permissions",
        "detection",
        "redaction",
        "pipeline",
        "schemas",
        "runtime",
        "optimizer",
        "debug",
        "benchmark",
        "audit",
        "replay_protection"
    ];
}
COMMENT "Retourne les capacités publiques du Security SDK."
PERMISSIONS FULL;
