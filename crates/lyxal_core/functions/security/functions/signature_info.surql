-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_signature_info
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_signature_info() -> object {
    RETURN {
        native_surrealql: false,
        supported_algorithms: [],
        status: "disabled_until_cto_approval",
        engine: "lyxal_crypto",
        private_keys_by_reference_only: true,
        canonicalization_required: true
    };
}
COMMENT "Documente le contrat de signatures asymétriques."
PERMISSIONS FULL;
