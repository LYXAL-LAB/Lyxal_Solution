-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/collection_paginate.surql
-- Fonction : fn::utils_collection_paginate
--
-- Pagine une collection.
--
-- Paramètres
--   $value     : array<any>
--   $page      : int
--   $page_size : int
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $page < 1 OR $page_size < 1
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_collection_paginate(
    $value: array<any>,
    $page: int,
    $page_size: int
) -> object {
    IF $page < 1 OR $page_size < 1 {
        THROW "CORE_INVALID_ARGUMENT";
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
