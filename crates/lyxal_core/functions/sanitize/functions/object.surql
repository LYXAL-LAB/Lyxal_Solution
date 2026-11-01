-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/object.surql
-- Fonction : fn::sanitize_object
--
-- Garantit un objet : NONE et NULL deviennent {}, un objet est renvoyé tel
-- quel. Exception documentée au contrat sanitize : cette fonction sert
-- justement à fournir un objet par défaut.
--
-- Paramètres
--   $value : any — valeur quelconque
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : un objet (jamais NONE)
--   Entrée          : exception : NONE et NULL → {} ; autre type → CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $clean = fn::sanitize_object($params.object);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_object(
    $value: any
) -> object {
    IF $value IS NONE OR type::is_null($value) { RETURN {}; };
    IF !type::is_object($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    RETURN $value;
}
COMMENT "Garantit un objet : NONE et NULL deviennent {}, un objet est renvoyé tel quel. Exception documentée au contrat sanitize : cette fonction sert justement à fournir un objet par défaut."
PERMISSIONS FULL;
