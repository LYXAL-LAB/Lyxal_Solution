-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/currency.surql
-- Fonction : fn::sanitize_currency
--
-- Extrait un montant d'une saisie monétaire : symboles (€ $ £ ¥), lettres et
-- espaces retirés, puis nettoyage localisé (voir sanitize_float).
--
-- Paramètres
--   $value             : any — valeur à nettoyer (chaîne, ou NONE)
--   $decimal_separator : string — séparateur décimal de la saisie : "," ou "." (l'autre est traité comme séparateur de milliers)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le montant en texte avec un point décimal
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Erreurs de programmation (THROW)
--   CORE_UNSUPPORTED_OPTION : séparateur autre que "," ou "."
--
-- Exemple
--   LET $amount = fn::sanitize_currency($params.price, ",");
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_currency(
    $value: any,
    $decimal_separator: string
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN fn::sanitize_float(string::replace($value, <regex>"[€$£¥A-Za-z\\s]", ""), $decimal_separator);
}
COMMENT "Extrait un montant d'une saisie monétaire : symboles (€ $ £ ¥), lettres et espaces retirés, puis nettoyage localisé (voir sanitize_float). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
