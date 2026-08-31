-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_token_parse
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_token_parse(
    $token: string
) -> object {
    LET $clean = string::trim($token);
    IF $clean = "" {
        THROW "SECURITY_EMPTY_TOKEN";
    };

    LET $parts = string::split($clean, "_");

    RETURN {
        raw: $clean,
        prefix: IF array::len($parts) > 1 { $parts[0] } ELSE { NONE },
        secret: IF array::len($parts) > 1 {
            array::join(array::slice($parts, 1, array::len($parts)), "_")
        } ELSE {
            $clean
        },
        length: string::len($clean)
    };
}
COMMENT "Analyse lexicalement un token opaque préfixé."
PERMISSIONS FULL;
