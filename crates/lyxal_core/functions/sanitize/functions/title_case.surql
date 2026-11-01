-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/title_case.surql
-- Fonction : fn::sanitize_title_case
--
-- Met la première lettre de chaque mot en majuscule et le reste en
-- minuscules.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la chaîne en casse de titre
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_title_case($params.title_case);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_title_case(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::capitalize(string::lowercase($value));
}
COMMENT "Met la première lettre de chaque mot en majuscule et le reste en minuscules. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
