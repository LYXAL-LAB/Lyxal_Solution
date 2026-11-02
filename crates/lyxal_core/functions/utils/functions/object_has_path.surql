-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/object_has_path.surql
-- Fonction : fn::utils_object_has_path
--
-- Vérifie l'existence d'un chemin d'objet.
--
-- Paramètres
--   $value : object
--   $path  : array<string>
--
-- Valeur renvoyée : bool (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_object_has_path(
    $value: object,
    $path: array<string>
) -> bool {
    IF array::len($path) = 0 {
        RETURN true;
    };

    RETURN array::fold(
        $path,
        {
            exists:true,
            current:$value
        },
        |$state,$segment| {
            IF !$state.exists
                OR !type::is_object($state.current)
                OR $state.current[$segment] IS NONE
            {
                {
                    exists:false,
                    current:NONE
                }
            } ELSE {
                {
                    exists:true,
                    current:$state.current[$segment]
                }
            }
        }
    ).exists;
}
COMMENT "Vérifie l'existence d'un chemin d'objet."
PERMISSIONS FULL;
