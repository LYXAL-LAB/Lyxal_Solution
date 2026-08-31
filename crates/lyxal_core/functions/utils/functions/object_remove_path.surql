-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_object_remove_path
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_object_remove_path(
    $value: object,
    $path: array<string>
) -> object {
    IF array::len($path) = 0 {
        RETURN $value;
    };

    LET $head = $path[0];

    RETURN IF array::len($path) = 1 {
        fn::utils_object_omit(
            $value,
            [$head]
        )
    } ELSE IF type::is_object($value[$head]) {
        object::extend(
            $value,
            object::from_entries([
                [
                    $head,
                    fn::utils_object_remove_path(
                        $value[$head],
                        array::slice($path,1,array::len($path))
                    )
                ]
            ])
        )
    } ELSE {
        $value
    };
}
COMMENT "Supprime récursivement une valeur d'un chemin d'objet."
PERMISSIONS FULL;
