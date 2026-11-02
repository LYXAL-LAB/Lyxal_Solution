-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/string_kebab_case.surql
-- Fonction : fn::utils_string_kebab_case
--
-- Convertit une chaîne en kebab-case : séparateur inséré entre une minuscule
-- (ou un chiffre) et une majuscule, minuscules, caractères hors [a-z0-9]
-- remplacés par « - ».
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_string_kebab_case(
    $value: string
) -> string {
    LET $chars = string::split(string::trim($value), "");
    LET $split = array::join(array::map($chars, |$char, $index|
        IF $index > 0 AND string::matches($char, "^[A-Z]$") AND string::matches($chars[$index - 1], "^[a-z0-9]$") { "-" + $char } ELSE { $char }
    ), "");
    LET $joined = string::replace(string::lowercase($split), <regex>"[^a-z0-9]+", "-");
    RETURN string::replace($joined, <regex>"^-+|-+$", "");
}
COMMENT "Convertit une chaîne en kebab-case : séparateur inséré entre une minuscule (ou un chiffre) et une majuscule, minuscules, caractères hors [a-z0-9] remplacés par « - »."
PERMISSIONS FULL;
