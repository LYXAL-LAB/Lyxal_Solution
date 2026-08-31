-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_signature_payload
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_signature_payload(
    $payload: any,
    $content_type: string
) -> string {
    LET $type = string::lowercase(string::trim($content_type));
    RETURN IF $type = "application/json" {
        encoding::json::encode($payload)
    } ELSE IF type::is_string($payload) {
        $payload
    } ELSE {
        encoding::json::encode($payload)
    };
}
COMMENT "Canonise un payload avant signature asymétrique."
PERMISSIONS FULL;
