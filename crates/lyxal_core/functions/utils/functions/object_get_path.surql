-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/object_get_path.surql
-- Fonction : fn::utils_object_get_path
--
-- Lit une valeur depuis un chemin d'objet.
--
-- Paramètres
--   $value         : object
--   $path          : array<string>
--   $default_value : any
--
-- Valeur renvoyée : any (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_object_get_path(
    $value: object,
    $path: array<string>,
    $default_value: any
) -> any {
    LET $result = array::fold(
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
    );

    RETURN IF $result.exists {
        $result.current
    } ELSE {
        $default_value
    };
}
COMMENT "Lit une valeur depuis un chemin d'objet."
PERMISSIONS FULL;
