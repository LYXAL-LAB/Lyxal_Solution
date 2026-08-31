-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_detect_open_redirect
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_detect_open_redirect(
    $value: string
) -> object {
    LET $input = string::lowercase(string::trim($value));

    LET $detected =
        string::starts_with($input,"//")
        OR string::matches($input,"^[a-z][a-z0-9+.-]*://")
        OR string::matches($input,"^(javascript|data|vbscript):");

    RETURN {
        detected: $detected,
        category: "open_redirect",
        score: IF $detected { 70 } ELSE { 0 },
        input: $input
    };
}
COMMENT "Détecte une redirection potentiellement externe ou dangereuse."
PERMISSIONS FULL;
