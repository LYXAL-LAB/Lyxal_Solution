-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_array_chunk
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_array_chunk(
    $value: array<any>,
    $size: int
) -> array<array<any>> {
    IF $size < 1 {
        THROW "UTILS_INVALID_CHUNK_SIZE";
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
