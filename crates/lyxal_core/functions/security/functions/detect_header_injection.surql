-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/detect_header_injection.surql
-- Fonction : fn::security_detect_header_injection
--
-- Détecte les retours de ligne utilisés pour l'injection d'en-têtes.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_detect_header_injection(
    $value: string
) -> object {
    LET $matches = array::filter(
        ["\\r","\\n","%0d","%0a"],
        |$pattern| string::matches(string::lowercase($value),$pattern)
    );

    RETURN {
        detected: array::len($matches) > 0,
        category: "header_injection",
        score: array::len($matches) * 30,
        matches: $matches
    };
}
COMMENT "Détecte les retours de ligne utilisés pour l'injection d'en-têtes."
PERMISSIONS FULL;
