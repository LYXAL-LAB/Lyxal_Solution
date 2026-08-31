-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_info
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_info() -> object {
    RETURN {
        name:"lyxal_core_security",
        version:"1.0.0",
        lots:17,
        function_count:170,
        engines:{
            surrealql:[
                "hash",
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
            ],
            native_rust:[
                "hmac",
                "constant_time_compare",
                "signatures",
                "authenticated_encryption",
                "key_management",
                "vault"
            ]
        }
    };
}
COMMENT "Retourne les informations générales du moteur Security."
PERMISSIONS FULL;
