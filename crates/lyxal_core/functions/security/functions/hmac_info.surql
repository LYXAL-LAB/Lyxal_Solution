-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hmac_info
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hmac_info() -> object {
    RETURN {
        native_surrealql: false,
        supported_contracts: ["hmac-sha256","hmac-sha512"],
        signer: "lyxal_security_native_rust",
        constant_time_verification_required: true,
        secret_storage: "reference_only"
    };
}
COMMENT "Documente le contrat HMAC du moteur Security."
PERMISSIONS FULL;
