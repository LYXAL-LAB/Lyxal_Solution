-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/collection_window.surql
-- Fonction : fn::utils_collection_window
--
-- Produit des fenêtres glissantes sur une collection.
--
-- Paramètres
--   $value : array<any>
--   $size  : int
--   $step  : int
--
-- Valeur renvoyée : array<array<any>> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $size < 1 OR $step < 1
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_collection_window(
    $value: array<any>,
    $size: int,
    $step: int
) -> array<array<any>> {
    IF $size < 1 OR $step < 1 {
        THROW "CORE_INVALID_ARGUMENT";
    };

    IF array::len($value) < $size {
        RETURN [];
    };

    LET $count = math::floor(
        (
            array::len($value)-$size
        ) / $step
    ) + 1;

    RETURN array::map(
        array::range(0,type::int($count)),
        |$index| array::slice(
            $value,
            $index*$step,
            ($index*$step)+$size
        )
    );
}
COMMENT "Produit des fenêtres glissantes sur une collection."
PERMISSIONS FULL;
