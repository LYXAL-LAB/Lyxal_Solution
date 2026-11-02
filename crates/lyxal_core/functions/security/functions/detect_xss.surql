-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/detect_xss.surql
-- Fonction : fn::security_detect_xss
--
-- Détecte heuristiquement plusieurs motifs XSS courants.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
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
