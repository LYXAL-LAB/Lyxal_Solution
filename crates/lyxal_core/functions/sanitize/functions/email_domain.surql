-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/email_domain.surql
-- Fonction : fn::sanitize_email_domain
--
-- Extrait le domaine d'une adresse e-mail (après le dernier « @ »), en
-- minuscules ; chaîne vide s'il n'y a pas de « @ ».
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : le domaine
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_email_domain($params.email_domain);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_email_domain(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $parts = string::split(string::lowercase(string::trim($value)), "@");
    RETURN IF array::len($parts) < 2 { "" } ELSE { array::last($parts) };
}
COMMENT "Extrait le domaine d'une adresse e-mail (après le dernier « @ »), en minuscules. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
