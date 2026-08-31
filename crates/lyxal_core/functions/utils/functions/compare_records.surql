-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_compare_records
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_compare_records(
    $left: object,
    $right: object,
    $keys: array<string>
) -> object {
    LET $changes = array::filter(
        array::map(
            $keys,
            |$key| {
                key:$key,
                left:$left[$key],
                right:$right[$key],
                changed:$left[$key] != $right[$key]
            }
        ),
        |$change| $change.changed
    );

    RETURN {
        equal:array::len($changes)=0,
        changes:$changes,
        change_count:array::len($changes)
    };
}
COMMENT "Compare deux records sur une liste de clés."
PERMISSIONS FULL;
