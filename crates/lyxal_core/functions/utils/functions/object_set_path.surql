-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_object_set_path
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_object_set_path(
    $value: object,
    $path: array<string>,
    $new_value: any
) -> object {
    IF array::len($path) = 0 {
        THROW "UTILS_EMPTY_OBJECT_PATH";
    };

    LET $head = $path[0];

    RETURN IF array::len($path) = 1 {
        object::extend(
            $value,
            object::from_entries([
                [$head,$new_value]
            ])
        )
    } ELSE {
        LET $child = IF type::is_object($value[$head]) {
            $value[$head]
        } ELSE {
            {}
        };

        object::extend(
            $value,
            object::from_entries([
                [
                    $head,
                    fn::utils_object_set_path(
                        $child,
                        array::slice($path,1,array::len($path)),
                        $new_value
                    )
                ]
            ])
        )
    };
}
COMMENT "Définit récursivement une valeur dans un chemin d'objet."
PERMISSIONS FULL;
