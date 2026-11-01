-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/integer.surql
-- Fonction : fn::sanitize_integer
--
-- Extrait d'une saisie texte un entier signé : signe « - » initial conservé,
-- tout caractère non numérique supprimé (« -1 234 » → « -1234 »).
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : les chiffres, précédés de « - » si la saisie commence par un tiret
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_integer($params.integer);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_integer(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $clean = string::trim($value);
    LET $digits = string::replace($clean, <regex>"[^0-9]", "");
    RETURN IF string::starts_with($clean, "-") AND $digits != "" { "-" + $digits } ELSE { $digits };
}
COMMENT "Extrait d'une saisie texte un entier signé : signe « - » initial conservé, tout caractère non numérique supprimé (« -1 234 » → « -1234 »). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
