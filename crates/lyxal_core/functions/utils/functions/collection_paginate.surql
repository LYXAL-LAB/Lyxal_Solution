-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_collection_paginate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_collection_paginate(
    $value: array<any>,
    $page: int,
    $page_size: int
) -> object {
    IF $page < 1 OR $page_size < 1 {
        THROW "UTILS_INVALID_PAGINATION";
    };

    LET $total = array::len($value);
    LET $offset = ($page-1)*$page_size;

    RETURN {
        page:$page,
        page_size:$page_size,
        total:$total,
        page_count:math::ceil(
            type::float($total)
            / type::float($page_size)
        ),
        items:array::slice(
            $value,
            $offset,
            $offset+$page_size
        )
    };
}
COMMENT "Pagine une collection."
PERMISSIONS FULL;
