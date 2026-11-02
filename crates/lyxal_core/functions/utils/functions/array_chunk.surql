-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/array_chunk.surql
-- Fonction : fn::utils_array_chunk
--
-- Découpe un tableau en groupes de taille fixe.
--
-- Paramètres
--   $value : array<any>
--   $size  : int
--
-- Valeur renvoyée : array<array<any>> (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $size < 1
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_array_chunk(
    $value: array<any>,
    $size: int
) -> array<array<any>> {
    IF $size < 1 {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN array::map(
        array::range(
            0,
            math::ceil(
                type::float(array::len($value))
                / type::float($size)
            )
        ),
        |$index| array::slice(
            $value,
            $index * $size,
            ($index + 1) * $size
        )
    );
}
COMMENT "Découpe un tableau en groupes de taille fixe."
PERMISSIONS FULL;
