-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/object_set_path.surql
-- Fonction : fn::utils_object_set_path
--
-- Définit récursivement une valeur dans un chemin d'objet.
--
-- Paramètres
--   $value     : object
--   $path      : array<string>
--   $new_value : any
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : array::len($path) = 0
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_object_set_path(
    $value: object,
    $path: array<string>,
    $new_value: any
) -> object {
    IF array::len($path) = 0 {
        THROW "CORE_INVALID_ARGUMENT";
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
