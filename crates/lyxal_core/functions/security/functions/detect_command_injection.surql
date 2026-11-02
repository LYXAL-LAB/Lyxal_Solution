-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/detect_command_injection.surql
-- Fonction : fn::security_detect_command_injection
--
-- Détecte heuristiquement plusieurs motifs de command injection.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_detect_command_injection(
    $value: string
) -> object {
    LET $input = string::lowercase($value);

    LET $patterns = [
        "(;|&&|\\|\\|)\\s*(sh|bash|cmd|powershell|curl|wget|nc)\\b",
        "`[^`]+`",
        "\\$\\([^\\)]+\\)",
        "\\b(rm|del)\\s+(-rf\\s+)?[/\\\\]",
        "\\bchmod\\s+[0-9]{3,4}\\b"
    ];

    LET $matches = array::filter(
        $patterns,
        |$pattern| string::matches($input,$pattern)
    );

    RETURN {
        detected: array::len($matches) > 0,
        category: "command_injection",
        score: array::len($matches) * 25,
        matches: $matches
    };
}
COMMENT "Détecte heuristiquement plusieurs motifs de command injection."
PERMISSIONS FULL;
