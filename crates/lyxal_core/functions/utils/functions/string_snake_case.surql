-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/string_snake_case.surql
-- Fonction : fn::utils_string_snake_case
--
-- Convertit une chaîne en snake_case : séparateur inséré entre une minuscule
-- (ou un chiffre) et une majuscule, minuscules, caractères hors [a-z0-9]
-- remplacés par « _ ».
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_string_snake_case(
    $value: string
) -> string {
    LET $chars = string::split(string::trim($value), "");
    LET $split = array::join(array::map($chars, |$char, $index|
        IF $index > 0 AND string::matches($char, "^[A-Z]$") AND string::matches($chars[$index - 1], "^[a-z0-9]$") { "_" + $char } ELSE { $char }
    ), "");
    LET $joined = string::replace(string::lowercase($split), <regex>"[^a-z0-9]+", "_");
    RETURN string::replace($joined, <regex>"^_+|_+$", "");
}
COMMENT "Convertit une chaîne en snake_case : séparateur inséré entre une minuscule (ou un chiffre) et une majuscule, minuscules, caractères hors [a-z0-9] remplacés par « _ »."
PERMISSIONS FULL;
