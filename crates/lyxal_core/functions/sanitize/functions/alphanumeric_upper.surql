-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/alphanumeric_upper.surql
-- Fonction : fn::sanitize_alphanumeric_upper
--
-- Normalise un identifiant alphanumérique (IBAN, BIC, référence…) :
-- majuscules, caractères hors [A-Z0-9] supprimés.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'identifiant en majuscules, sans séparateur
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $iban = fn::sanitize_alphanumeric_upper($params.iban);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_alphanumeric_upper(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::replace(string::uppercase($value), <regex>"[^A-Z0-9]", "");
}
COMMENT "Normalise un identifiant alphanumérique (IBAN, BIC, référence…) : majuscules, caractères hors [A-Z0-9] supprimés. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
