-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_detect_path_traversal
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_detect_path_traversal(
    $value: string
) -> object {
    LET $input = string::lowercase($value);

    LET $patterns = [
        "\\.\\./",
        "\\.\\.\\\\",
        "%2e%2e%2f",
        "%2e%2e/",
        "%252e%252e",
        "/etc/passwd",
        "windows/system32"
    ];

    LET $matches = array::filter(
        $patterns,
        |$pattern| string::matches($input,$pattern)
    );

    RETURN {
        detected: array::len($matches) > 0,
        category: "path_traversal",
        score: array::len($matches) * 25,
        matches: $matches
    };
}
COMMENT "Détecte heuristiquement plusieurs motifs de path traversal."
PERMISSIONS FULL;
