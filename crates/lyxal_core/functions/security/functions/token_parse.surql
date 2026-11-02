-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/token_parse.surql
-- Fonction : fn::security_token_parse
--
-- Analyse lexicalement un token opaque préfixé.
--
-- Paramètres
--   $token : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $clean = ""
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_token_parse(
    $token: string
) -> object {
    LET $clean = string::trim($token);
    IF $clean = "" {
        THROW "CORE_INVALID_ARGUMENT";
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
