-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_debug_export
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_debug_export($session:object,$format:string)->string{
 LET $f=string::lowercase(string::trim($format));
 RETURN IF $f="json"{encoding::json::encode(fn::sanitize_debug_report($session))}ELSE{THROW "SANITIZE_DEBUG_UNSUPPORTED_EXPORT_FORMAT"};
}
COMMENT "Exporte un rapport de debug au format JSON."
PERMISSIONS FULL;
