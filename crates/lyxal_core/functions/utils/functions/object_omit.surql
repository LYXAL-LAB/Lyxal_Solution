-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/object_omit.surql
-- Fonction : fn::utils_object_omit
--
-- Retire les clés demandées d'un objet.
--
-- Paramètres
--   $value : object
--   $keys  : array<string>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_object_omit(
    $value: object,
    $keys: array<string>
) -> object {
    RETURN object::from_entries(
        array::filter(
            object::entries($value),
            |$entry| !(($keys) CONTAINS ($entry[0]))
        )
    );
}
COMMENT "Retire les clés demandées d'un objet."
PERMISSIONS FULL;
