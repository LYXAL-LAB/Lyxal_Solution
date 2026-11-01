-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/array.surql
-- Fonction : fn::sanitize_array
--
-- Garantit un tableau : NONE et NULL deviennent [], un tableau est renvoyé
-- tel quel, toute autre valeur est enveloppée dans un tableau. Exception
-- documentée au contrat sanitize : cette fonction sert justement à fournir
-- une collection par défaut.
--
-- Paramètres
--   $value : any — valeur quelconque
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : un tableau (jamais NONE)
--   Entrée          : exception : NONE et NULL → [] ; ne lève jamais d'erreur
--
-- Exemple
--   LET $clean = fn::sanitize_array($params.array);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_array(
    $value: any
) -> array {
    IF $value IS NONE OR type::is_null($value) { RETURN []; };
    RETURN IF type::is_array($value) { $value } ELSE { [$value] };
}
COMMENT "Garantit un tableau : NONE et NULL deviennent [], un tableau est renvoyé tel quel, toute autre valeur est enveloppée dans un tableau. Exception documentée au contrat sanitize : cette fonction sert justement à fournir une collection par défaut."
PERMISSIONS FULL;
