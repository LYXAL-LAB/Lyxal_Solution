-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/decimal.surql
-- Fonction : fn::sanitize_decimal
--
-- Extrait d'une saisie texte un nombre décimal : signe « - » initial
-- conservé, virgule convertie en point, caractères non numériques supprimés,
-- seul le premier point est conservé.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le nombre décimal en texte (ex. « -1234.56 »)
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_decimal($params.decimal);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_decimal(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $clean = string::trim($value);
    LET $parts = string::split(string::replace(string::replace($clean, ",", "."), <regex>"[^0-9.]", ""), ".");
    LET $number = IF array::len($parts) <= 1 { $parts[0] } ELSE { $parts[0] + "." + array::join(array::slice($parts, 1), "") };
    RETURN IF string::starts_with($clean, "-") AND $number != "" { "-" + $number } ELSE { $number };
}
COMMENT "Extrait d'une saisie texte un nombre décimal : signe « - » initial conservé, virgule convertie en point, caractères non numériques supprimés, seul le premier point est conservé. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
