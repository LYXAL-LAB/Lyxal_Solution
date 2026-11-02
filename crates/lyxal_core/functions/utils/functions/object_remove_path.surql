-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/object_remove_path.surql
-- Fonction : fn::utils_object_remove_path
--
-- Supprime récursivement une valeur d'un chemin d'objet.
--
-- Paramètres
--   $value : object
--   $path  : array<string>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
