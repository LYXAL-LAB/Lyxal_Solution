-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/sanitize/functions/object_normalize.surql
-- Fonction : fn::sanitize_object_normalize
--
-- Normalise un objet en trois étapes facultatives : filtrage des clés
-- autorisées, complément par les valeurs par défaut, retrait des valeurs
-- vides (NULL, chaînes, tableaux et objets vides).
--
-- Paramètres
--   $value        : any — valeur à nettoyer (objet, ou NONE)
--   $allowed_keys : option<array<string>> — clés conservées, NONE pour toutes
--   $defaults     : option<object> — valeurs par défaut, NONE pour aucune
--   $remove_empty : bool — retirer les valeurs vides
--
-- Contrat sanitize (crates/lyxal_core/Readme.md)
--   Valeur renvoyée : l'objet normalisé
--   Entrée          : NONE → NONE ; NULL ou mauvais type → THROW CORE_SANITIZE_INVALID_TYPE
--
-- Exemple
--   LET $input = fn::sanitize_object_normalize($params, ["name", "language"], { language: "fr" }, true);
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_object_normalize(
    $value: any,
    $allowed_keys: option<array<string>>,
    $defaults: option<object>,
    $remove_empty: bool
) -> option<object> {
    IF $value IS NONE { RETURN NONE; };
    IF !type::is_object($value) { THROW "CORE_SANITIZE_INVALID_TYPE"; };
    LET $kept = IF $allowed_keys IS NONE { $value } ELSE { fn::sanitize_remove_unknown_keys($value, $allowed_keys) };
    LET $completed = IF $defaults IS NONE { $kept } ELSE { fn::sanitize_default_values($kept, $defaults) };
    RETURN IF $remove_empty { fn::sanitize_remove_empty($completed, true, true, true, true) } ELSE { $completed };
}
COMMENT "Normalise un objet en trois étapes facultatives : filtrage des clés autorisées, complément par les valeurs par défaut, retrait des valeurs vides (NULL, chaînes, tableaux et objets vides). NONE → NONE ; mauvais type → CORE_SANITIZE_INVALID_TYPE."
PERMISSIONS FULL;
