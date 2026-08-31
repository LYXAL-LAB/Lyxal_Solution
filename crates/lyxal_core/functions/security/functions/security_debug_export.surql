-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_debug_export
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_debug_export(
    $session: object,
    $format: string
) -> string {
    LET $clean_format = string::lowercase(string::trim($format));

    RETURN IF $clean_format = "json" {
        encoding::json::encode(fn::security_debug_report($session))
    } ELSE {
        THROW "SECURITY_DEBUG_UNSUPPORTED_EXPORT_FORMAT"
    };
}
COMMENT "Exporte un rapport Security au format JSON."
PERMISSIONS FULL;
