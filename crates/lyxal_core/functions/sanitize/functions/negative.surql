-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/negative.surql
-- Fonction : fn::sanitize_negative
--
-- Extrait un nombre décimal d'une saisie texte (voir sanitize_decimal) et le
-- rend négatif.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le nombre précédé de « - » (chaîne vide si aucun chiffre)
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_negative($params.negative);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_negative(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $number = string::replace(fn::sanitize_decimal($value), <regex>"^-", "");
    RETURN IF $number = "" { "" } ELSE { "-" + $number };
}
COMMENT "Extrait un nombre décimal d'une saisie texte (voir sanitize_decimal) et le rend négatif. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
