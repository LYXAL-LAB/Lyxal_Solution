-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/string_reverse.surql
-- Fonction : fn::utils_string_reverse
--
-- Inverse les caractères d'une chaîne.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_string_reverse(
    $value: string
) -> string {
    RETURN array::join(
        array::reverse(
            string::split($value,"")
        ),
        ""
    );
}
COMMENT "Inverse les caractères d'une chaîne."
PERMISSIONS FULL;
