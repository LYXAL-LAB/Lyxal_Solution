-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_redact_log
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_redact_log(
    $message: string
) -> string {
    LET $value = $message;

    LET $value = string::replace(
        $value,
        <regex>"(?i)(authorization\\s*:\\s*bearer\\s+)[A-Za-z0-9._~-]+",
        "$1***REDACTED***"
    );

    LET $value = string::replace(
        $value,
        <regex>"(?i)(api[_-]?key\\s*[=:]\\s*)[^\\s,;]+",
        "$1***REDACTED***"
    );

    LET $value = string::replace(
        $value,
        <regex>"(?i)(password\\s*[=:]\\s*)[^\\s,;]+",
        "$1***REDACTED***"
    );

    RETURN $value;
}
COMMENT "Masque plusieurs formes courantes de secrets dans un log."
PERMISSIONS FULL;
