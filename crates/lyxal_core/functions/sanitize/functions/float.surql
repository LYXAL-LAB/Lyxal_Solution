-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/float.surql
-- Fonction : fn::sanitize_float
--
-- Extrait d'une saisie texte localisée un nombre à virgule : séparateur de
-- milliers supprimé, séparateur décimal converti en point, signe « - »
-- initial conservé.
--
-- Paramètres
--   $value             : any — valeur à nettoyer (chaîne, ou NONE)
--   $decimal_separator : string — séparateur décimal de la saisie : "," ou "." (l'autre est traité comme séparateur de milliers)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le nombre en texte avec un point décimal (ex. « -1234.5 »)
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : séparateur autre que "," ou "."
--
-- Exemple
--   LET $amount = fn::sanitize_float($params.amount, ",");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_float(
    $value: any,
    $decimal_separator: string
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    IF $decimal_separator NOT IN [",", "."] { THROW "CORE_UNSUPPORTED_OPTION"; };
    LET $clean = string::trim($value);
    LET $thousands = IF $decimal_separator = "," { "." } ELSE { "," };
    LET $number = string::replace(string::replace(string::replace($clean, <regex>"[^0-9.,]", ""), $thousands, ""), ",", ".");
    RETURN IF string::starts_with($clean, "-") AND $number != "" { "-" + $number } ELSE { $number };
}
COMMENT "Extrait d'une saisie texte localisée un nombre à virgule : séparateur de milliers supprimé, séparateur décimal converti en point, signe « - » initial conservé. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
