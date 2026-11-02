-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/detect_path_traversal.surql
-- Fonction : fn::security_detect_path_traversal
--
-- Détecte heuristiquement plusieurs motifs de path traversal.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
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
