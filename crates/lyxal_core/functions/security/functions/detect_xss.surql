-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_detect_xss
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_detect_xss(
    $value: string
) -> object {
    LET $input = string::lowercase($value);

    LET $patterns = [
        "<script\\b",
        "javascript:",
        "on[a-z]+\\s*=",
        "<iframe\\b",
        "<svg\\b",
        "data:text/html",
        "document\\.cookie",
        "window\\.location"
    ];

    LET $matches = array::filter(
        $patterns,
        |$pattern| string::matches($input,$pattern)
    );

    RETURN {
        detected: array::len($matches) > 0,
        category: "xss",
        score: array::len($matches) * 20,
        matches: $matches
    };
}
COMMENT "Détecte heuristiquement plusieurs motifs XSS courants."
PERMISSIONS FULL;
