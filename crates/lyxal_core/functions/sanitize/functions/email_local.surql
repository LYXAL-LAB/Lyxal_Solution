-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/email_local.surql
-- Fonction : fn::sanitize_email_local
--
-- Extrait la partie locale d'une adresse e-mail (avant « @ »), préfixe «
-- mailto: » retiré.
--
-- Paramètres
--   $value : any — valeur à nettoyer (chaîne, ou NONE)
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : la partie locale
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_email_local($params.email_local);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_email_local(
    $value: any
) -> option<string> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_string($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN string::split(string::replace(string::trim($value), <regex>"^mailto:", ""), "@")[0];
}
COMMENT "Extrait la partie locale d'une adresse e-mail (avant « @ »), préfixe « mailto: » retiré. NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
