-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/slug.surql
-- Fonction : fn::sanitize_slug
--
-- Transforme une chaîne en slug : minuscules, toute suite de caractères hors
-- [a-z0-9] remplacée par le séparateur, séparateurs retirés en début et en
-- fin. Les lettres accentuées sont traitées comme des séparateurs.
--
-- Paramètres
--   $value     : any — valeur à nettoyer (chaîne, ou NONE)
--   $separator : string — "-" ou "_" ("" vaut "-")
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le slug
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : séparateur autre que "-", "_" ou ""
--
-- Exemple
--   LET $slug = fn::sanitize_slug($params.title, "-");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_slug(
    $value: any,
    $separator: string
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $sep = IF $separator = "" { "-" } ELSE { $separator };
    IF $sep NOT IN ["-", "_"] { THROW "CORE_UNSUPPORTED_OPTION"; };
    LET $joined = string::replace(string::lowercase(string::trim($value)), <regex>"[^a-z0-9]+", $sep);
    RETURN string::replace($joined, <regex>"^[-_]+|[-_]+$", "");
}
COMMENT "Transforme une chaîne en slug : minuscules, toute suite de caractères hors [a-z0-9] remplacée par le séparateur, séparateurs retirés en début et en fin. Les lettres accentuées sont traitées comme des séparateurs. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
