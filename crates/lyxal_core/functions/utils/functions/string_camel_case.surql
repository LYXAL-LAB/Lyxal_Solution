-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/string_camel_case.surql
-- Fonction : fn::utils_string_camel_case
--
-- Transforme une chaîne en camelCase : mots séparés par les caractères hors
-- [A-Za-z0-9] et par le passage d'une minuscule (ou d'un chiffre) à une
-- majuscule ; premier mot en minuscules, suivants capitalisés.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_string_camel_case(
    $value: string
) -> string {
    LET $chars = string::split(string::trim($value), "");
    LET $split = array::join(array::map($chars, |$char, $index|
        IF $index > 0 AND string::matches($char, "^[A-Z]$") AND string::matches($chars[$index - 1], "^[a-z0-9]$") { " " + $char } ELSE { $char }
    ), "");
    LET $words = array::filter(string::split(string::replace($split, <regex>"[^A-Za-z0-9]+", " "), " "), |$word| $word != "");
    RETURN array::join(array::map($words, |$word, $index| IF $index = 0 { string::lowercase($word) } ELSE { string::capitalize(string::lowercase($word)) }), "");
}
COMMENT "Transforme une chaîne en camelCase : mots séparés par les caractères hors [A-Za-z0-9] et par le passage d'une minuscule (ou d'un chiffre) à une majuscule ; premier mot en minuscules, suivants capitalisés."
PERMISSIONS FULL;
