-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_object_get_path
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_object_get_path(
    $value: object,
    $path: array<string>,
    $default_value: option<any>
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
