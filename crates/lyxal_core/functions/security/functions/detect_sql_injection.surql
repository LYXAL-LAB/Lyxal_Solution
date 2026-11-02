-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/detect_sql_injection.surql
-- Fonction : fn::security_detect_sql_injection
--
-- Détecte heuristiquement plusieurs motifs SQL injection courants.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_detect_sql_injection(
    $value: string
) -> object {
    LET $input = string::lowercase($value);

    LET $patterns = [
        "\\bunion\\s+select\\b",
        "\\bselect\\b.*\\bfrom\\b",
        "\\binsert\\s+into\\b",
        "\\bupdate\\b.*\\bset\\b",
        "\\bdelete\\s+from\\b",
        "\\bdrop\\s+(table|database)\\b",
        "(--|/\\*|\\*/)",
        "\\bor\\s+1\\s*=\\s*1\\b"
    ];

    LET $matches = array::filter(
        $patterns,
        |$pattern| string::matches($input,$pattern)
    );

    RETURN {
        detected: array::len($matches) > 0,
        category: "sql_injection",
        score: array::len($matches) * 20,
        matches: $matches
    };
}
COMMENT "Détecte heuristiquement plusieurs motifs SQL injection courants."
PERMISSIONS FULL;
